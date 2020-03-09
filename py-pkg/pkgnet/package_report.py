from pathlib import Path

from pkgnet.abstract_package_reporter import AbstractPackageReporter
from pkgnet.html_dependencies import HtmlDependencies

from jinja2 import Environment, PackageLoader, select_autoescape
import webbrowser


_JINJA_ENV = Environment(
    loader=PackageLoader("pkgnet", "templates"), autoescape=select_autoescape(["html", "xml"]),
)


class PackageReport:

    _report_template = _JINJA_ENV.get_template("package_report.jinja")

    _html_dependencies = HtmlDependencies(
        scripts=["jquery-3.4.1.min.js", "popper.min.js", "bootstrap.min.js"],
        stylesheets=["bootstrap.min.css"],
    )

    def __init__(self, pkg_name, report_path, pkg_path=None):
        # TODO: Validation

        self._pkg_name = pkg_name
        self._report_path = Path(report_path).expanduser().resolve()
        self._pkg_path = Path(pkg_path).expanduser().resolve() if pkg_path is not None else None
        self._reporters = dict()

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

    @property
    def reporters(self):
        return [reporter for reporter in self._reporters.values()]

    @property
    def html_dependencies(self):
        return sum(
            [self._html_dependencies] + [reporter.html_dependencies for reporter in self.reporters],
            HtmlDependencies(),
        )

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


def _reporter_property(reporter_class, docstring=None):
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


def register_reporter(cls):
    if not issubclass(cls, AbstractPackageReporter):
        raise TypeError("Only subclasses of AbstractPackageReporter can be registered.")
    setattr(PackageReport, cls.__name__, _reporter_property(cls))
    return cls
