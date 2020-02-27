from pkgnet.abstract_package_reporter import AbstractPackageReporter

from pkg_resources import get_distribution
from email import message_from_string
import pandas as pd


class SummaryReporter(AbstractPackageReporter):

    report_template = "tab_summary_report.jinja"
    report_slug = "summary-report"
    report_name = "Package Summary"

    def __init__(self):
        self._pkg_name = None
        self._pkg_summary = None

    @property
    def pkg_summary(self):
        if self._pkg_summary is None:
            self._get_package_summary()
        return self._pkg_summary

    def get_summary_view(self):
        print(self.pkg_summary)
        df = pd.DataFrame.from_records([self.pkg_summary]).transpose()
        print(df)
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

    def _get_package_summary(self):
        pkg_metadata = get_distribution(self.pkg_name).get_metadata("METADATA")
        # parse it using email.Parser
        msg = message_from_string(pkg_metadata)
        self._pkg_summary = dict(msg)
