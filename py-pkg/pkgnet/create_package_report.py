from pkgnet.package_report import PackageReport
from pkgnet.summary_reporter import SummaryReporter
from pkgnet.dependency_reporter import DependencyReporter
from pkgnet.function_reporter import FunctionReporter


def default_reporters():
    return [SummaryReporter(), DependencyReporter(), FunctionReporter()]


def create_package_report(pkg_name, report_path, pkg_reporters=None, pkg_path=None):
    if pkg_reporters is None:
        pkg_reporters = default_reporters()
    # TODO: Validation

    created_report = PackageReport(pkg_name=pkg_name, pkg_path=pkg_path, report_path=report_path)

    for reporter in pkg_reporters:
        created_report.add_reporter(reporter)

    created_report.render_report()

    return created_report
