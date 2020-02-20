from importlib import import_module


class AbstractPackageReporter:
    def __init__(self):
        self._pkg_name = None

    @property
    def pkg_name(self):
        return self._pkg_name

    def set_package(self, pkg_name, pkg_path=None):
        # Packages can only be set once
        if self._pkg_name is not None:
            # TODO: Better exception classing
            raise Exception(
                "A package has already been set for this reporter. "
                + "Please instantiate a new reporter to set a new package."
            )

        # TODO: Add validation for pkg_name

        self._pkg_name = pkg_name

        # Load package
        import_module(self.pkg_name)

        # TODO: Implement pkg_path
        if pkg_path is not None:
            raise NotImplementedError("pkg_path not yet implemented")

        return self
