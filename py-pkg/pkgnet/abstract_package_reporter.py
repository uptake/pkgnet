from abc import ABC
from importlib import import_module


class _ReporterRegistrar:
    def __init__(self):
        self.available_reporters = {}
        self.callbacks = []

    def register_reporter(self, cls: type):
        if not issubclass(cls, AbstractPackageReporter):
            raise TypeError("Only subclasses of AbstractPackageReporter can be registered.")
        self.available_reporters[cls.__name__] = cls
        # Run callbacks so that listeners can update with new reporters
        for callback in self.callbacks:
            callback(self.available_reporters)
        return cls


registrar = _ReporterRegistrar()
available_reporters = registrar.available_reporters


class AbstractPackageReporter(ABC):
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
