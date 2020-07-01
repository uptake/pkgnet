from email import message_from_string
from typing import Callable, Optional

try:
    import importlib.resources as importlib_resources
except ImportError:
    # Python 3.6 uses importlib_resources backport
    import importlib_resources

import pandas as pd
from pkg_resources import get_distribution

from pkgnet.abstract_package_reporter import AbstractPackageReporter
from pkgnet.html_dependencies import HtmlDependencies
from pkgnet.abstract_package_reporter import registrar


@registrar.register_reporter
class SummaryReporter(AbstractPackageReporter):

    report_template = "tab_summary_report.jinja"
    report_slug = "summary-report"
    report_name = "Package Summary"

    _html_dependencies = HtmlDependencies(
        scripts=["jquery-3.4.1.min.js", "datatables.min.js"], stylesheets=["datatables.min.css"]
    )

    def __init__(self):
        self._pkg_name = None
        self._pkg_summary = None

    ### PUBLIC METHODS ###

    def get_summary_view(self):
        df = pd.DataFrame.from_records([self.pkg_summary]).transpose()
        datatables_init_script = f"""
            <script>
                $(document).ready( function () {{
                    $('#{self.report_slug}-table').DataTable();
                }} );
            </script>
        """
        return (
            df.to_html(classes=["display"], table_id=f"{self.report_slug}-table")
            + datatables_init_script
        )

    @classmethod
    def report_template(cls) -> (str, str, Optional[Callable]):
        source = importlib_resources.read_text("pkgnet.templates", "tab_summary_report.jinja")
        path = next(importlib_resources.path("pkgnet.templates", "tab_summary_report.jinja").gen)
        mtime = path.stat().st_mtime  # last modified time
        return source, str(path), lambda: path.stat().st_mtime == mtime

    ### PROPERTIES ###

    @property
    def pkg_summary(self):
        if self._pkg_summary is None:
            self._get_package_summary()
        return self._pkg_summary

    @property
    def html_dependencies(self):
        return self._html_dependencies

    def _get_package_summary(self):
        pkg_metadata = get_distribution(self.pkg_name).get_metadata("METADATA")
        # parse it using email.Parser
        msg = message_from_string(pkg_metadata)
        self._pkg_summary = dict(msg)
