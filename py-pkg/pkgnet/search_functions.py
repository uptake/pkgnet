import sys
import pkgutil
from importlib import import_module


def get_object(obj_name):
    """Given a fully qualified object name, returns that object.

    Args:
        obj_name (str): fully qualified object name

    Returns:
        that object
    """
    # Edge case: builtins.module is actually types.ModuleType
    if obj_name == "builtins.module":
        obj_name = "types.ModuleType"
    parts = obj_name.rsplit(".", 1)
    return getattr(import_module(parts[0]), parts[1])


def safe_import_module(module):
    try:
        return import_module(module)
    except ModuleNotFoundError:
        # Sometimes non-public facing modules are included in a package, such as tests
        # These may have undeclared dependencies, so we can't load them.
        return None


def get_fully_qualified_name(obj):
    """Given an object, returns that object's fully qualified name. A fully qualified
    name includes the full dot-path of modules and submodules.

    Args:
        obj: some object

    Returns:
        str: fully qualified name of that object
    """
    return f"{obj.__module__}.{obj.__qualname__}"


def get_all_package_modules(pkg_name):

    module_set = _recursive_node_search(pkg_name, get_submodules)

    return module_set


def get_submodules(module_name):
    module = sys.modules.get(module_name, None)
    if module is None:
        return []
    module_path = getattr(module, "__path__", None)
    if module_path is None:
        return []
    return [
        f"{module_name}.{submodule_name}"
        for _, submodule_name, _ in pkgutil.iter_modules(module_path)
    ]


def _recursive_node_search(node, search_function, seen_nodes=None, nodes_to_ignore=None):
    if seen_nodes is None:
        seen_nodes = set()
    if nodes_to_ignore is None:
        nodes_to_ignore = set()

    # Add self to seen_nodes
    seen_nodes.add(node)

    # Get connected nodes and search
    connected_nodes = set(search_function(node))
    nodes_to_search = connected_nodes - seen_nodes - nodes_to_ignore

    for search_node in nodes_to_search:
        _recursive_node_search(
            search_node, search_function, seen_nodes=seen_nodes, nodes_to_ignore=nodes_to_ignore,
        )

    return seen_nodes
