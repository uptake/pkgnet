import networkx as nx
import pandas as pd


class AbstractGraph:
    _nx_graph_class = None

    def __init__(self, nodes, edges):
        self._nodes = nodes
        self._edges = edges
        self._nx_graph = None

    @property
    def nodes(self):
        return self._nodes

    @property
    def edges(self):
        return self._edges

    @property
    def nx_graph(self):
        if self._nx_graph is None:
            self.initialize_nx_graph()
        return self._nx_graph

    def node_measures(self, measures=None):
        # If not specifying, return entire node table
        if measures is None:
            return self.nodes

        for m in measures:
            # TODO: Input validation

            # If not already calculated it, calculate and add to node dataframe
            if m not in self.nodes.columns:
                result = getattr(self.NodeMeasureFunctions, m)(self.nx_graph)
                self.nodes[m] = self.nodes.index.map(lambda n: result[n])

        return self.nodes[measures]

    def graph_measures(self, measures=None):
        pass

    def compute_layout(self, layout):
        # Validation
        layout_func = getattr(nx.drawing.layout, layout, None)
        if layout_func is None:
            # TODO: raise exception
            pass
        positions = layout_func(self.nx_graph)
        positions_df = pd.DataFrame.from_records(positions).transpose()
        positions_df.columns = ["x", "y"]
        return positions_df

    ### PRIVATE METHODS ###

    def initialize_nx_graph(self):
        # Connected graph
        connected_graph = nx.convert_matrix.from_pandas_edgelist(
            self.edges, source="SOURCE", target="TARGET", create_using=self._nx_graph_class,
        )

        # Unconnected graph
        unconnected_graph = self._nx_graph_class()
        unconnected_graph.add_nodes_from(self.nodes.index.values)

        # Combine graphs
        complete_graph = nx.compose(connected_graph, unconnected_graph)

        self._nx_graph = complete_graph

    class NodeMeasureFunctions:
        pass


class DirectedGraph(AbstractGraph):
    _nx_graph_class = nx.DiGraph

    @property
    def default_node_measures(self):
        return [
            "out_degree",
            "in_degree",
            "num_recursive_deps",
            "num_recursive_rev_deps",
            "betweenness",
            "pagerank",
        ]

    # Dispatch table for node measure functions
    class NodeMeasureFunctions:
        @staticmethod
        def out_degree(nx_graph):
            return {node: degree for node, degree in nx_graph.out_degree()}

        @staticmethod
        def in_degree(nx_graph):
            return {node: degree for node, degree in nx_graph.in_degree()}

        @staticmethod
        def out_closeness(nx_graph):
            return nx.algorithms.centrality.closeness_centrality(nx_graph.reverse())

        @staticmethod
        def in_closeness(nx_graph):
            return nx.algorithms.centrality.closeness_centrality(nx_graph)

        @staticmethod
        def num_recursive_deps(nx_graph):
            return {
                node: len(nx.algorithms.shortest_paths.generic.shortest_path(nx_graph, source=node))
                for node in nx_graph.nodes
            }

        @staticmethod
        def num_recursive_rev_deps(nx_graph):
            return {
                node: len(
                    nx.algorithms.shortest_paths.generic.shortest_path(
                        nx_graph.reverse(), source=node
                    )
                )
                for node in nx_graph.nodes
            }

        @staticmethod
        def betweenness(nx_graph):
            return nx.algorithms.centrality.betweenness_centrality(nx_graph)

        @staticmethod
        def pagerank(nx_graph):
            return nx.algorithms.link_analysis.pagerank_alg.pagerank(nx_graph)
