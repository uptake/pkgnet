import inspect
from typing import Callable, Optional

try:
    import importlib.resources as importlib_resources
except ImportError:
    # Python 3.6 uses importlib_resources backport
    import importlib_resources


import pandas as pd

from pkgnet.abstract_graph_reporter import AbstractGraphReporter
from pkgnet.graphs import DirectedGraph
from pkgnet.package_report import registrar
from pkgnet.search_utils import (
    get_all_modules_in_package,
    get_fully_qualified_name,
    get_package_name,
    safe_import_module,
)


@registrar.register_reporter
class ImportReporter(AbstractGraphReporter):

    _graph_class = DirectedGraph

    report_template = "tab_import_report.jinja"
    report_slug = "import-report"
    report_name = "Imported Modules"
    layout = "kamada_kawai_layout"

    def __init__(self):
        super().__init__()
        self._ignore_packages = []

    ### PUBLIC METHODS ###

    @classmethod
    def report_template(cls) -> (str, str, Optional[Callable]):
        # Implements jinja2 Loader get_source interface
        # https://jinja.palletsprojects.com/en/2.11.x/api/#loaders
        source = importlib_resources.read_text("pkgnet.templates", "tab_import_report.jinja")
        path = next(importlib_resources.path("pkgnet.templates", "tab_import_report.jinja").gen)
        modified_time = path.stat().st_mtime  # last modified time
        return source, str(path), lambda: path.stat().st_mtime == modified_time

    ### PROPERTIES ###

    ### PRIVATE METHODS ###

    def _extract_nodes_and_edges(self):
        if self.pkg_name is None:
            raise AttributeError("pkg_name is not set for this reporter.")

        pkg_modules = get_all_modules_in_package(self.pkg_name)

        # TODO: Something about edge search is not deterministic. figure this out

        # Edges
        dfs = []
        for module in pkg_modules:
            imports = get_imported_modules(module)
            # If module A imports module B, then A -> B
            # A is the SOURCE and B is the TARGET
            # This is UML dependency convention
            dfs.append(pd.DataFrame({"SOURCE": [module] * len(imports), "TARGET": imports}))

        self._edges = pd.concat(dfs, axis=0, ignore_index=True)

        # Nodes
        all_modules = set(self.edges["SOURCE"].values) | set(self.edges["TARGET"].values)
        self._nodes = pd.DataFrame(index=all_modules)
        self.nodes["package"] = self.nodes.index.map(get_package_name)


def get_imported_modules(module_name: str):

    module_obj = safe_import_module(module_name)
    import_names = []
    if module_obj is None:
        return import_names
    for _, member_obj in inspect.getmembers(module_obj):
        if inspect.ismodule(member_obj):
            # Member is itself a module ("import x")
            import_names.append(get_fully_qualified_name(member_obj))
        else:
            # Get all modules imported with "from x import y"
            member_module = getattr(member_obj, "__module__", None)
            if member_module is not None and member_module not in (module_name, "buildins"):
                import_names.append(member_module)
    return import_names
