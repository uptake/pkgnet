from pkgnet.abstract_package_reporter import AbstractPackageReporter
from pkgnet.graph_viz import VisJs
from abc import abstractmethod


class AbstractGraphReporter(AbstractPackageReporter):

    _graph_class = None

    def __init__(self, viz_class=VisJs):
        super().__init__()
        self._nodes = None
        self._edges = None
        self._pkg_graph = None
        self._graph_viz = None
        self._viz_class = viz_class

    ### PROPERTIES ###

    @property
    def nodes(self):
        if self._nodes is None:
            self._extract_nodes()
        return self._nodes

    @property
    def edges(self):
        if self._edges is None:
            self._extract_edges()
        return self._edges

    @property
    def network_measures(self):
        pass

    @property
    def pkg_graph(self):
        if self._pkg_graph is None:
            self._pkg_graph = self._graph_class(nodes=self.nodes, edges=self.edges)
        return self._pkg_graph

    @property
    def graph_viz(self):
        if self._graph_viz is None:
            self._graph_viz = self.viz_class(nodes=self.nodes, edges=self.edges)
        return self._graph_viz

    @property
    def viz_class(self):
        return self._viz_class

    @viz_class.setter
    def viz_class(self, value):
        # TODO: Validation
        self._viz_class = value

    ### PUBLIC METHODS ###

    def calculate_default_measures(self):
        # TODO
        raise NotImplementedError
        return self

    def summary_view(self):
        # TODO
        raise NotImplementedError
        return self

    ### PRIVATE METHODS ###

    @abstractmethod
    def _extract_nodes(self):
        raise NotImplementedError("Node extraction not implemented for this reporter.")

    @abstractmethod
    def _extract_edges(self):
        raise NotImplementedError("Edge extraction not implemented for this reporter.")
