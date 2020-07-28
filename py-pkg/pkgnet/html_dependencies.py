class HtmlDependencies:
    scripts = []
    stylesheets = []

    @property
    def script_blocks(self):
        return [SCRIPT_BLOCKS[script] for script in self.scripts]

    @property
    def stylesheet_blocks(self):
        return [STYLESHEET_BLOCKS[stylesheet] for stylesheet in self.stylesheets]

    def __init__(self, scripts=[], stylesheets=[]):
        # Remove duplicates, preserve ordering
        self.scripts = sorted(set(scripts), key=scripts.index)
        self.stylesheets = sorted(set(stylesheets), key=stylesheets.index)

    def __add__(self, right):
        scripts = self.scripts + right.scripts
        stylesheets = self.stylesheets + right.stylesheets
        return HtmlDependencies(scripts=scripts, stylesheets=stylesheets)


SCRIPT_BLOCKS = {
    "bootstrap.min.js": """
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js"
            integrity="sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6"
            crossorigin="anonymous"></script>
    """,
    "cytoscape.min.js": """
        <script src="https://cdnjs.cloudflare.com/ajax/libs/cytoscape/3.14.0/cytoscape.min.js"
            integrity="sha256-rI7zH7xDqO306nxvXUw9gqkeBpvvmddDdlXJjJM7rEM="
            crossorigin="anonymous"></script>
    """,
    "datatables.min.js": """
        <script type="text/javascript"
            src="https://cdn.datatables.net/v/dt/dt-1.10.20/fc-3.3.0/fh-3.1.6/datatables.min.js">
            </script>
    """,
    "jquery-3.4.1.min.js": """
        <script
            src="https://code.jquery.com/jquery-3.4.1.min.js"
            integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo="
            crossorigin="anonymous"></script>
    """,
    "popper.min.js": """
        <script src="https://unpkg.com/@popperjs/core@2"></script>
    """,
    "vis-network.min.js": """
        <script type="text/javascript"
            src="https://unpkg.com/vis-network/standalone/umd/vis-network.min.js"></script>
    """,
    "sigma.min.js": """
        <script src="https://cdnjs.cloudflare.com/ajax/libs/sigma.js/1.2.1/sigma.min.js"
        integrity="sha256-ii2D7w2jthCadZtIl2OjRn2vu1iEtGWcOrmd+UOZorc="
        crossorigin="anonymous"></script>
    """,
}

STYLESHEET_BLOCKS = {
    "bootstrap.min.css": """
        <link href="https://stackpath.bootstrapcdn.com/bootswatch/4.4.1/flatly/bootstrap.min.css"
            rel="stylesheet"
            integrity="sha384-yrfSO0DBjS56u5M+SjWTyAHujrkiYVtRYh2dtB3yLQtUz3bodOeialO59u5lUCFF"
            crossorigin="anonymous">
    """,
    "datatables.min.css": """
        <link rel="stylesheet" type="text/css"
            href="https://cdn.datatables.net/v/dt/dt-1.10.20/fc-3.3.0/fh-3.1.6/datatables.min.css"/>
    """,
}
