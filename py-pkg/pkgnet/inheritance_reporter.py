import inspect
import sys
import pandas as pd

from pkgnet.abstract_graph_reporter import AbstractGraphReporter
from pkgnet.graphs import DirectedGraph
from pkgnet.search_functions import (
    get_all_package_modules,
    get_object,
    get_fully_qualified_name,
    _recursive_node_search,
)


class InheritanceReporter(AbstractGraphReporter):

    _graph_class = DirectedGraph

    ### PROPERTIES ###

    ### PUBLIC METHODS ###

    ### PRIVATE METHODS ###

    def _extract_nodes(self):
        if self.pkg_name is None:
            raise AttributeError("pkg_name is not set for this reporter.")

        modules = get_all_package_modules(self.pkg_name)

        # Get all classes used in modules
        classes = []
        for module_name in modules:
            if module_name not in sys.modules.keys():
                # Need to import it first
                # import_module(module_name)
                # Maybe intentionally not imported? Skip?
                continue
            module_obj = sys.modules[module_name]
            classes += [
                # Need to get name from object, because class may be imported
                get_fully_qualified_name(get_object(f"{module_name}.{class_name}"))
                for class_name, _ in inspect.getmembers(module_obj, inspect.isclass)
            ]

        # Keep only classes defined in this package
        # Other classes may be imported to be used in functions
        classes = [
            class_name
            for class_name in classes
            if class_name.split(".", 1)[0] == self.pkg_name
        ]

        # Search classes for ancestors
        searched_classes = set()
        for class_name in classes:
            _recursive_node_search(
                class_name, self._get_parent_classes, seen_nodes=searched_classes
            )
        searched_classes = list(searched_classes)

        self._nodes = pd.DataFrame(
            {
                "node": searched_classes,
                "package": [
                    class_name.split(".", 1)[0] for class_name in searched_classes
                ],
            }
        )

    def _extract_edges(self):
        if self.pkg_name is None:
            raise AttributeError("pkg_name is not set for this reporter.")

        dfs = []
        for class_name in self.nodes["node"].values:
            parent_class_names = self._get_parent_classes(class_name)
            # If class A is child of class B, then A -> B
            # A is the SOURCE and B is the TARGET
            # This is UML class inheritance convention
            dfs.append(
                pd.DataFrame(
                    {
                        "SOURCE": [class_name] * len(parent_class_names),
                        "TARGET": parent_class_names,
                    }
                )
            )

        self._edges = pd.concat(dfs, axis=0, ignore_index=True)

    @staticmethod
    def _get_parent_classes(class_name):
        class_obj = get_object(class_name)
        parent_class_objs = class_obj.__bases__
        parent_class_names = [
            get_fully_qualified_name(parent_class_obj)
            for parent_class_obj in parent_class_objs
        ]
        return parent_class_names
