import pandas as pd
import pkg_resources

from pkgnet.abstract_graph_reporter import AbstractGraphReporter
from pkgnet.graphs import DirectedGraph
from pkgnet.abstract_package_reporter import registrar
from pkgnet.search_utils import recursive_node_search


@registrar.register_reporter
class DependencyReporter(AbstractGraphReporter):

    _graph_class = DirectedGraph

    report_template = "tab_dependency_report.jinja"
    report_slug = "dependency-report"
    report_name = "Dependencies"
    layout = "kamada_kawai_layout"

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self._ignore_packages = []

    ### PROPERTIES ###

    ### PUBLIC METHODS ###

    ### PRIVATE METHODS ###

    def _extract_nodes_and_edges(self):
        if self.pkg_name is None:
            raise AttributeError("pkg_name is not set for this reporter.")

        # If pkg A depends on pkg B, then A -> B
        # A is the SOURCE and B is the TARGET
        # This is UML dependency convention
        nodes, edges = recursive_node_search(self.pkg_name, get_package_dependencies)

        # Set nodes df
        self._nodes = pd.DataFrame(index=nodes)
        self._edges = pd.DataFrame(edges)


def get_package_dependencies(pkg_name):
    return [
        requirement.key for requirement in pkg_resources.working_set.by_key[pkg_name].requires()
    ]
