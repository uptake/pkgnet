import pkgutil
import sys
from collections import namedtuple
from importlib import import_module
from inspect import ismodule


def get_object(obj_name: str):
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


def safe_import_module(module_name: str):
    try:
        return import_module(module_name)
    # Sometimes non-public facing modules are included in a package, such as tests
    # These may have undeclared dependencies, so we can't load them.
    except ModuleNotFoundError:
        return None
    except ImportError:
        return None


def get_fully_qualified_name(obj):
    """Given an object, returns that object's fully qualified name. A fully qualified
    name includes the full dot-path of modules and submodules.

    Args:
        obj: some object

    Returns:
        str: fully qualified name of that object
    """
    if ismodule(obj):
        return obj.__name__
    return f"{obj.__module__}.{obj.__qualname__}"


def get_package_name(obj_name: str):
    """Given a fully qualified object name, return the name of the package that the object belongs
    to.

    Args:
        obj_name (str): fully qualified object name

    Returns:
        str: name of package containing object
    """
    return obj_name.split(".", 1)[0]


def get_all_modules_in_package(pkg_name: str):

    modules, _ = recursive_node_search(pkg_name, get_submodules)

    return list(modules)


def get_submodules(module_name: str):
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


Edge = namedtuple("Edge", ("SOURCE", "TARGET"))


def recursive_node_search(
    node: str, search_function, seen_nodes=None, seen_edges=None, nodes_to_ignore=None
):
    if seen_nodes is None:
        seen_nodes = set()
    if seen_edges is None:
        seen_edges = set()
    if nodes_to_ignore is None:
        nodes_to_ignore = set()

    # Add self to seen_nodes
    seen_nodes.add(node)

    # Get connected nodes and search
    connected_nodes = set(search_function(node)) - nodes_to_ignore

    seen_edges |= {Edge(SOURCE=node, TARGET=neighbor) for neighbor in connected_nodes}

    nodes_to_search = connected_nodes - seen_nodes
    for search_node in nodes_to_search:
        recursive_node_search(
            search_node, search_function, seen_nodes=seen_nodes, nodes_to_ignore=nodes_to_ignore,
        )

    return (seen_nodes, seen_edges)
