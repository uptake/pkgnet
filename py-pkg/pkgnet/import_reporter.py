import inspect
import pandas as pd

from pkgnet.abstract_graph_reporter import AbstractGraphReporter
from pkgnet.graphs import DirectedGraph
from pkgnet.search_functions import get_all_package_modules, safe_import_module


class ImportReporter(AbstractGraphReporter):

    _graph_class = DirectedGraph

    def __init__(self):
        super().__init__()
        self._ignore_packages = []

    ### PROPERTIES ###

    ### PUBLIC METHODS ###

    ### PRIVATE METHODS ###

    def _extract_nodes(self):
        return self._extract_nodes_and_edges()

    def _extract_edges(self):
        return self._extract_nodes_and_edges()

    def _extract_nodes_and_edges(self):
        if self.pkg_name is None:
            raise AttributeError("pkg_name is not set for this reporter.")

        pkg_modules = get_all_package_modules(self.pkg_name)

        # TODO: Something about edge search is not deterministic. figure this out

        # Set edges df
        dfs = []
        for module in pkg_modules:
            imports = self._get_imported_modules(module)
            # If module A imports module B, then A -> B
            # A is the SOURCE and B is the TARGET
            # This is UML dependency convention
            dfs.append(pd.DataFrame({"SOURCE": [module] * len(imports), "TARGET": imports}))

        self._edges = pd.concat(dfs, axis=0, ignore_index=True)

        internal_nodes = pd.DataFrame(
            {"node": list(pkg_modules), "type": ["internal"] * len(pkg_modules)}
        )

        external_modules = [
            module for module in self.edges["TARGET"].values if module not in pkg_modules
        ]
        external_nodes = pd.DataFrame(
            {"node": external_modules, "type": ["external"] * len(external_modules)}
        )

        self._nodes = pd.concat([internal_nodes, external_nodes], axis=0, ignore_index=True)

    @staticmethod
    def _get_imported_modules(module_name):
        module_obj = safe_import_module(module_name)
        imports = []
        if module_obj is None:
            return imports
        for member_name, member_obj in inspect.getmembers(module_obj):
            if inspect.ismodule(member_obj):
                imports.append(member_name)
            else:
                member_module = getattr(member_obj, "__module__", None)
                if member_module is not None and member_module not in (module_name, "buildins"):
                    imports.append(member_module)
        return imports
