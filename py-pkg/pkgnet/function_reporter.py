import inspect

import pandas as pd

from pkgnet.abstract_graph_reporter import AbstractGraphReporter
from pkgnet.graphs import DirectedGraph
from pkgnet.abstract_package_reporter import registrar
from pkgnet.search_utils import (
    get_all_modules_in_package,
    get_fully_qualified_name,
    get_object,
    get_package_name,
    safe_import_module,
)


@registrar.register_reporter
class FunctionReporter(AbstractGraphReporter):

    _graph_class = DirectedGraph

    report_template = "tab_function_report.jinja"
    report_slug = "function-report"
    report_name = "Functions"
    layout = "kamada_kawai_layout"

    ### PROPERTIES ###

    ### PUBLIC METHODS ###

    ### PRIVATE METHODS ###

    def _extract_nodes_and_edges(self):
        if self.pkg_name is None:
            raise AttributeError("pkg_name is not set for this reporter.")

        modules = get_all_modules_in_package(self.pkg_name)

        # Get all functions used in modules
        pkg_fcns = set()
        for module_name in modules:
            module_obj = safe_import_module(module_name)
            if module_obj is None:
                continue
            pkg_fcns |= {
                get_fully_qualified_name(fcn_object)
                for _, fcn_object in inspect.getmembers(module_obj, inspect.isfunction)
                # Only want functions defined in this module, not imported functions
                if fcn_object.__module__ == module_name
            }

        # Edges
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

        # Nodes
        all_fcns = set(self.edges["SOURCE"].values) | set(self.edges["TARGET"].values)
        self._nodes = pd.DataFrame(index=all_fcns)
        self.nodes["package"] = self.nodes.index.map(get_package_name)

    def _get_called_functions(self, fcn_name):
        fcn_obj = get_object(fcn_name)
        referenced_names = fcn_obj.__code__.co_names
        module = safe_import_module(fcn_obj.__module__)
        referenced_objs = [getattr(module, ref_name, None) for ref_name in referenced_names]
        referenced_fcn_names = [
            get_fully_qualified_name(obj)
            for obj in referenced_objs
            if obj is not None and is_package_function(obj, self.pkg_name)
        ]
        return referenced_fcn_names


def is_package_function(obj, pkg_name):
    return inspect.isfunction(obj) and is_package_object(obj, pkg_name=pkg_name)


def is_package_object(obj, pkg_name):
    return get_package_name(obj.__module__) == pkg_name
