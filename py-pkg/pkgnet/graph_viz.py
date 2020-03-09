import json
from random import randrange
from pkgnet.html_dependencies import HtmlDependencies


class AbstractVis:
    viz_template = None

    def __init__(self, reporter):
        self._reporter = reporter

    ### PROPERTIES ###
    @property
    def reporter(self):
        return self._reporter

    @property
    def nodes(self):
        return self.reporter.nodes

    @property
    def edges(self):
        return self.reporter.edges


class VisJs(AbstractVis):
    viz_template = "viz_visjs.jinja"
    html_dependencies = HtmlDependencies(scripts=["vis-network.min.js"])

    scale_factor = 1000

    ### PUBLIC METHODS ###

    def nodes_to_json(self):
        positions_df = self.reporter.pkg_graph.compute_layout(self.reporter.layout)
        return json.dumps(
            [
                {
                    "id": row.Index,
                    "label": row.Index,
                    "x": positions_df.loc[row.Index, "x"] * self.scale_factor,
                    "y": positions_df.loc[row.Index, "y"] * self.scale_factor,
                }
                for row in self.nodes.itertuples(index=True)
            ]
        )

    def edges_to_json(self):
        return json.dumps(
            [
                {"from": row.SOURCE, "to": row.TARGET, "color": "#848484"}
                for row in self.edges.itertuples(index=True)
            ]
        )


class SigmaJs(AbstractVis):
    viz_template = "viz_sigmajs.jinja"
    html_dependencies = HtmlDependencies(scripts=["sigma.min.js"])

    def nodes_to_json(self):
        return json.dumps(
            [
                {
                    "id": row.Index,
                    "label": row.Index,
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
    html_dependencies = HtmlDependencies(scripts=["cytoscape.min.js"])

    def nodes_to_json(self):
        return json.dumps(
            [{"data": {"id": row.Index}} for row in self.nodes.itertuples(index=True)]
        )

    def edges_to_json(self):
        return json.dumps(
            [
                {"data": {"id": row.Index, "source": row.SOURCE, "target": row.TARGET}}
                for row in self.edges.itertuples(index=True)
            ]
        )
