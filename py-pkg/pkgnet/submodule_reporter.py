from typing import Callable, Optional

try:
    import importlib.resources as importlib_resources
except ImportError:
    # Python 3.6 uses importlib_resources backport
    import importlib_resources

import pandas as pd

from pkgnet.abstract_graph_reporter import AbstractGraphReporter
from pkgnet.graphs import DirectedGraph
from pkgnet.abstract_package_reporter import registrar
from pkgnet.search_utils import get_all_modules_in_package, get_submodules


@registrar.register_reporter
class SubmoduleReporter(AbstractGraphReporter):

    _graph_class = DirectedGraph

    report_template = "tab_module_report.jinja"
    report_slug = "module-report"
    report_name = "Package Modules"
    layout = "kamada_kawai_layout"

    def __init__(self):
        super().__init__()
        self._ignore_packages = []

    ### PUBLIC METHODS ###

    @classmethod
    def report_template(cls) -> (str, str, Optional[Callable]):
        source = importlib_resources.read_text("pkgnet.templates", "tab_submodule_report.jinja")
        path = next(importlib_resources.path("pkgnet.templates", "tab_submodule_report.jinja").gen)
        mtime = path.stat().st_mtime  # last modified time
        return source, str(path), lambda: path.stat().st_mtime == mtime

    ### PROPERTIES ###

    ### PRIVATE METHODS ###

    def _extract_nodes_and_edges(self):
        if self.pkg_name is None:
            raise AttributeError("pkg_name is not set for this reporter.")

        # Nodes
        self._nodes = pd.DataFrame(index=get_all_modules_in_package(self.pkg_name))

        # Edges
        dfs = []
        for module in self.nodes.index.values:
            submodules = get_submodules(module)
            # If module A is submodule of module B, then A -> B
            # A is the SOURCE and B is the TARGET
            # This is UML dependency convention
            dfs.append(pd.DataFrame({"SOURCE": [module] * len(submodules), "TARGET": submodules}))

        self._edges = pd.concat(dfs, axis=0, ignore_index=True)
