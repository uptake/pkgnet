import atexit
import webbrowser
from pathlib import Path
from tempfile import TemporaryDirectory
from typing import Dict, Iterable, Optional, Union

try:
    import importlib.resources as pkg_resources
except ImportError:
    # Try backported to PY<37 `importlib_resources`.
    import importlib_resources as pkg_resources

from jinja2 import (
    BaseLoader,
    ChoiceLoader,
    Environment,
    PackageLoader,
    select_autoescape,
    TemplateNotFound,
)

from pkgnet.abstract_package_reporter import AbstractPackageReporter, registrar
from pkgnet.html_dependencies import HtmlDependencies
from pkgnet.abstract_graph_reporter import AbstractGraphReporter
from pkgnet.dependency_reporter import DependencyReporter
from pkgnet.function_reporter import FunctionReporter
from pkgnet.summary_reporter import SummaryReporter


def default_reporters():
    return [
        SummaryReporter(),
        DependencyReporter(),
        FunctionReporter(),
    ]


class ReporterTemplateLoader(BaseLoader):
    def __init__(self, available_reporters: Dict[str, AbstractPackageReporter]):
        self.available_reporters = available_reporters

    def get_source(self, environment, template):
        if template not in self.available_reporters:
            raise TemplateNotFound(template)
        return self.available_reporters[template].report_template()


jinja_env = Environment(
    loader=ChoiceLoader(
        [
            ReporterTemplateLoader(available_reporters=registrar.available_reporters),
            PackageLoader("pkgnet", "templates"),
        ]
    ),
    autoescape=select_autoescape(["html", "xml"]),
)


class PackageReport:

    _report_template = jinja_env.get_template("package_report.jinja")
    _html_dependencies = HtmlDependencies(
        scripts=["jquery-3.4.1.min.js", "popper.min.js", "bootstrap.min.js"],
        stylesheets=["bootstrap.min.css"],
    )

    def __init__(
        self,
        pkg_name: str,
        pkg_path: Optional[Union[Path, str]] = None,
        report_path: Optional[Union[Path, str]] = None,
    ):
        # TODO: Validation

        self._pkg_name = pkg_name
        if report_path is not None:
            self._report_path = Path(report_path).expanduser().resolve()
        else:
            temp_dir = TemporaryDirectory()
            atexit.register(temp_dir.cleanup)
            self._report_path = Path(temp_dir.name) / f"{pkg_name}.html"
        self._pkg_path = Path(pkg_path).expanduser().resolve() if pkg_path is not None else None
        self._reporters = dict()

    ### PUBLIC METHODS ###

    def add_reporter(self, reporter):
        setattr(self, reporter.__class__.__name__, reporter)
        return self

    def render_report(self):
        rendered_report = self._report_template.render(
            pkg_name=self.pkg_name,
            reporters=self.reporters,
            html_dependencies=self.html_dependencies,
        )

        with open(self.report_path, "w+") as report_file:
            report_file.write(rendered_report)
            webbrowser.open(self.report_path.as_uri())

    ### PROPERTIES ###

    @property
    def pkg_name(self):
        return self._pkg_name

    @property
    def pkg_path(self):
        return self._pkg_path

    @property
    def report_path(self):
        return self._report_path

    # Properties for individual reporter classes are registered by set_report_properties

    @property
    def reporters(self):
        return [reporter for reporter in self._reporters.values()]

    @property
    def html_dependencies(self):
        return sum(
            [self._html_dependencies] + [reporter.html_dependencies for reporter in self.reporters],
            HtmlDependencies(),
        )


def _reporter_property(reporter_class: type, docstring: Optional[str] = None):
    """Property factory for reporters.

    Args:
        reporter_class ([type]): [description]
        docstring ([type], optional): [description]. Defaults to None.

    Returns:
        [type]: [description]
    """

    def getter(self):
        return self._reporters[reporter_class.__name__]

    def setter(self, reporter):
        if not isinstance(reporter, reporter_class):
            raise TypeError(
                f"Cannot assign object of type {reporter.__class__} "
                + "to slot for {reporter_class.__name__}."
            )
        self._reporters[reporter_class.__name__] = reporter
        reporter.set_package(pkg_name=self.pkg_name, pkg_path=self.pkg_path)

    return property(getter, setter, doc=docstring)


def set_report_properties(available_reporters: Dict[str, AbstractPackageReporter]):
    for reporter_name, reporter_class in available_reporters.items():
        if not hasattr(PackageReport, reporter_name):
            setattr(PackageReport, reporter_name, _reporter_property(reporter_class))


registrar.callbacks.append(set_report_properties)


def create_package_report(
    pkg_name: str,
    pkg_reporters: Optional[Iterable[AbstractPackageReporter]] = None,
    pkg_path: Optional[Union[Path, str]] = None,
    report_path: Optional[Union[Path, str]] = None,
):
    if pkg_reporters is None:
        pkg_reporters = default_reporters()
    # TODO: Validation

    created_report = PackageReport(pkg_name=pkg_name, pkg_path=pkg_path, report_path=report_path)

    for reporter in pkg_reporters:
        created_report.add_reporter(reporter)
        if isinstance(reporter, AbstractGraphReporter):
            reporter.calculate_default_measures()

    created_report.render_report()

    return created_report
