import json
from random import randrange


class AbstractVis:
    viz_template = None

    def __init__(self, nodes, edges):
        self._nodes = nodes
        self._edges = edges

    ### PROPERTIES ###

    @property
    def nodes(self):
        return self._nodes

    @property
    def edges(self):
        return self._edges


class VisJs(AbstractVis):
    viz_template = "viz_visjs.jinja"

    ### PUBLIC METHODS ###

    def nodes_to_json(self):
        return json.dumps(
            [{"id": row.node, "label": row.node} for row in self.nodes.itertuples(index=True)]
        )

    def edges_to_json(self):
        return json.dumps(
            [{"from": row.SOURCE, "to": row.TARGET} for row in self.edges.itertuples(index=True)]
        )


class SigmaJs(AbstractVis):
    viz_template = "viz_sigmajs.jinja"

    def nodes_to_json(self):
        return json.dumps(
            [
                {
                    "id": row.node,
                    "label": row.node,
                    "size": 2,
                    "x": randrange(0, 800),
                    "y": randrange(0, 800),
                }
                for row in self.nodes.itertuples(index=True)
            ]
        )

    def edges_to_json(self):
        return json.dumps(
            [
                {"id": row.Index, "source": row.SOURCE, "target": row.TARGET}
                for row in self.edges.itertuples(index=True)
            ]
        )


class CytoscapeJs(AbstractVis):
    viz_template = "viz_cytoscapejs.jinja"

    def nodes_to_json(self):
        return json.dumps([{"data": {"id": row.node}} for row in self.nodes.itertuples(index=True)])

    def edges_to_json(self):
        return json.dumps(
            [
                {"data": {"id": row.Index, "source": row.SOURCE, "target": row.TARGET}}
                for row in self.edges.itertuples(index=True)
            ]
        )
