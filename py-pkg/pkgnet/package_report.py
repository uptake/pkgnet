from pathlib import Path

from pkgnet.summary_reporter import SummaryReporter
from pkgnet.dependency_reporter import DependencyReporter
from pkgnet.function_reporter import FunctionReporter
from pkgnet.module_reporter import ModuleReporter
from pkgnet.import_reporter import ImportReporter
from pkgnet.inheritance_reporter import InheritanceReporter

from jinja2 import Environment, PackageLoader, select_autoescape
import webbrowser


_JINJA_ENV = Environment(
    loader=PackageLoader("pkgnet", "templates"), autoescape=select_autoescape(["html", "xml"]),
)


class PackageReport:

    _report_template = _JINJA_ENV.get_template("package_report.jinja")

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
    def summary_reporter(self):
        return self._reporters["SummaryReporter"]

    @summary_reporter.setter
    def summary_reporter(self, reporter):
        self._set_reporter(reporter, expected_class=SummaryReporter)

    @property
    def dependency_reporter(self):
        return self._reporters["DependencyReporter"]

    @dependency_reporter.setter
    def dependency_reporter(self, reporter):
        self._set_reporter(reporter, expected_class=DependencyReporter)

    @property
    def module_reporter(self):
        return self._reporters["ModuleReporter"]

    @module_reporter.setter
    def module_reporter(self, reporter):
        self._set_reporter(reporter, expected_class=ModuleReporter)

    @property
    def function_reporter(self):
        return self._reporters["FunctionReporter"]

    @function_reporter.setter
    def function_reporter(self, reporter):
        self._set_reporter(reporter, expected_class=FunctionReporter)

    @property
    def import_reporter(self):
        return self._reporters["ImportReporter"]

    @import_reporter.setter
    def import_reporter(self, reporter):
        self._set_reporter(reporter, expected_class=ImportReporter)

    @property
    def inheritance_reporter(self):
        return self._reporters["InheritanceReporter"]

    @inheritance_reporter.setter
    def inheritance_reporter(self, reporter):
        self._set_reporter(reporter, expected_class=InheritanceReporter)

    ### PUBLIC METHODS ###

    def add_reporter(self, reporter):
        self._set_reporter(reporter, expected_class=reporter.__class__)
        return self

    def render_report(self):
        rendered_report = self._report_template.render(
            pkg_name=self.pkg_name, reporters=self.reporters
        )

        with open(self.report_path, "w+") as report_file:
            report_file.write(rendered_report)
            webbrowser.open(self.report_path.as_uri())

    ### PRIVATE METHODS ###

    def _set_reporter(self, reporter, expected_class):
        # TODO: Validation

        self._reporters[expected_class.__name__] = reporter
        reporter.set_package(pkg_name=self.pkg_name, pkg_path=self.pkg_path)


def create_package_report(pkg_name, pkg_reporters, pkg_path, report_path):
    # TODO: Validation

    created_report = PackageReport(pkg_name=pkg_name, pkg_path=pkg_path, report_path=report_path)

    for reporter in pkg_reporters:
        created_report.add_reporter(reporter)

    return created_report


def default_reporters():
    return [DependencyReporter()]
