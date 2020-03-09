import inspect
import pandas as pd

from pkgnet.abstract_graph_reporter import AbstractGraphReporter
from pkgnet.graphs import DirectedGraph
from pkgnet.search_utils import (
    get_all_modules_in_package,
    get_object,
    get_fully_qualified_name,
    safe_import_module,
    recursive_node_search,
    get_package_name,
)
from pkgnet.package_report import register_reporter


@register_reporter
class InheritanceReporter(AbstractGraphReporter):

    _graph_class = DirectedGraph

    report_template = "tab_inheritance_report.jinja"
    report_slug = "inheritance-report"
    report_name = "Class Inheritance"
    layout = "kamada_kawai_layout"

    ### PROPERTIES ###

    ### PUBLIC METHODS ###

    ### PRIVATE METHODS ###

    def _extract_nodes_and_edges(self):
        if self.pkg_name is None:
            raise AttributeError("pkg_name is not set for this reporter.")

        pkg_modules = get_all_modules_in_package(self.pkg_name)

        # Get all classes defined in modules
        pkg_classes = set()
        for module_name in pkg_modules:
            module_obj = safe_import_module(module_name)
            if module_obj is None:
                continue
            pkg_classes |= {
                get_fully_qualified_name(class_obj)
                for _, class_obj in inspect.getmembers(module_obj, inspect.isclass)
                # Only want classes defined in this module, not imported
                if class_obj.__module__ == module_name
            }

        # Search classes for ancestors
        nodes = set()
        edges = set()
        for class_name in pkg_classes:
            # If class A is child of class B, then A -> B
            # A is the SOURCE and B is the TARGET
            # This is UML class inheritance convention
            recursive_node_search(
                class_name, get_parent_classes, seen_nodes=nodes, seen_edges=edges
            )

        self._nodes = pd.DataFrame(index=nodes)
        self.nodes["package"] = self.nodes.index.map(get_package_name)

        self._edges = pd.DataFrame(edges)


def get_parent_classes(class_name):
    class_obj = get_object(class_name)
    parent_class_objs = class_obj.__bases__
    parent_class_names = [
        get_fully_qualified_name(parent_class_obj) for parent_class_obj in parent_class_objs
    ]
    return parent_class_names
