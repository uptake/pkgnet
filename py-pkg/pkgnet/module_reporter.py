import pandas as pd

from pkgnet.abstract_graph_reporter import AbstractGraphReporter
from pkgnet.graphs import DirectedGraph
from pkgnet.search_functions import get_all_package_modules, get_submodules


class ModuleReporter(AbstractGraphReporter):

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

        self._nodes = pd.DataFrame(
            {"node": list(get_all_package_modules(self.pkg_name))}
        )

    def _extract_edges(self):
        if self.pkg_name is None:
            raise AttributeError("pkg_name is not set for this reporter.")

        # Set edges df
        dfs = []
        for module in self.nodes["node"].values:
            submodules = get_submodules(module)
            # If module A is child of module B, then A -> B
            # A is the SOURCE and B is the TARGET
            # This is UML dependency convention
            dfs.append(
                pd.DataFrame(
                    {"SOURCE": [module] * len(submodules), "TARGET": submodules}
                )
            )

        self._edges = pd.concat(dfs, axis=0, ignore_index=True)
