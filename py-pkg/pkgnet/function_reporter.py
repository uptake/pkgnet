import inspect
import pandas as pd

from pkgnet.abstract_graph_reporter import AbstractGraphReporter
from pkgnet.graphs import DirectedGraph
from pkgnet.search_functions import (
    get_all_package_modules,
    get_object,
    get_fully_qualified_name,
    safe_import_module,
)


class FunctionReporter(AbstractGraphReporter):

    _graph_class = DirectedGraph

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

        modules = get_all_package_modules(self.pkg_name)

        # Get all functions used in modules
        pkg_fcns = []
        for module_name in modules:
            module_obj = safe_import_module(module_name)
            if module_obj is None:
                continue
            pkg_fcns += [
                # Need to get name from object, because class may be imported
                get_fully_qualified_name(get_object(f"{module_name}.{function_name}"))
                for function_name, _ in inspect.getmembers(module_obj, inspect.isfunction)
            ]

        dfs = []
        for fcn_name in pkg_fcns:
            called_fcns = self._get_called_functions(fcn_name)
            # If function A calls function B, then A -> B
            # A is the SOURCE and B is the TARGET
            # This is UML dependency convention
            dfs.append(
                pd.DataFrame({"SOURCE": [fcn_name] * len(called_fcns), "TARGET": called_fcns})
            )

        self._edges = pd.concat(dfs, axis=0, ignore_index=True)

        internal_nodes = pd.DataFrame({"node": pkg_fcns, "type": ["internal"] * pkg_fcns})

        external_fcns = [fcn for fcn in self.edges["TARGET"].values if fcn not in pkg_fcns]
        external_nodes = pd.DataFrame({"node": external_fcns, "type": ["external"] * len(pkg_fcns)})

        self._nodes = pd.concat([internal_nodes, external_nodes], axis=0, ignore_index=True)

    @staticmethod
    def _get_called_functions(fcn_name):
        fcn_obj = get_object(fcn_name)
        referenced_names = fcn_obj.__code__.co_names
        module = safe_import_module(fcn_obj.__module__)
        referenced_objs = [getattr(module, ref_name) for ref_name in referenced_names]
        referenced_fcn_names = [
            get_fully_qualified_name(obj) for obj in referenced_objs if is_package_function(obj)
        ]
        return referenced_fcn_names


def is_package_function(obj, pkg_name):
    return inspect.isfunction and is_package_object(obj, pkg_name=pkg_name)


def is_package_object(obj, pkg_name):
    module_name = obj.__module__
    return module_name.split(".", 1)[0] == pkg_name
