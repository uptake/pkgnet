import pkg_resources
import pandas as pd

from pkgnet.abstract_graph_reporter import AbstractGraphReporter
from pkgnet.graphs import DirectedGraph
from pkgnet.search_functions import _recursive_node_search


class DependencyReporter(AbstractGraphReporter):

    _graph_class = DirectedGraph

    def __init__(self):
        super().__init__()
        self._ignore_packages = []

    ### PROPERTIES ###

    ### PUBLIC METHODS ###

    ### PRIVATE METHODS ###

    def _extract_nodes(self):
        if self.pkg_name is None:
            raise AttributeError("pkg_name is not set for this reporter.")

        self._extract_nodes_and_edges()

    def _extract_edges(self):
        if self.pkg_name is None:
            raise AttributeError("pkg_name is not set for this reporter.")

        self._extract_nodes_and_edges()

    def _extract_nodes_and_edges(self):
        # Check that package has been set
        # TODO

        # Recursively list dependencies, terminating search at ignore_package nodes
        # all_dependencies = self.recursive_dependencies(self.pkg_name)
        all_dependencies = _recursive_node_search(self.pkg_name, self.dependencies)

        # Set nodes df
        self._nodes = pd.DataFrame({"node": list(all_dependencies)})

        # Set edges df
        dfs = []
        for pkg in all_dependencies:
            deps = self.dependencies(pkg)
            # If pkg A depends on pkg B, then A -> B
            # A is the SOURCE and B is the TARGET
            # This is UML dependency convention
            dfs.append(pd.DataFrame({"SOURCE": [pkg] * len(deps), "TARGET": deps}))

        self._edges = pd.concat(dfs, axis=0, ignore_index=True)

    @staticmethod
    def get_dependencies(pkg_name):
        return [
            requirement.key for requirement in pkg_resources.working_set.by_key[pkg_name].requires()
        ]
