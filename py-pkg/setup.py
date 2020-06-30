from pathlib import Path
from setuptools import setup

INSTALL_REQUIREMENTS_FILE = Path(__file__).parent / "requirements.txt"


def load_requirements(path: Path):
    requirements = []
    with path.open("r") as fp:
        for line in fp.readlines():
            if line.startswith("-r"):
                requirements += load_requirements(line.split(" ")[1].strip())
            else:
                requirement = line.strip()
                if requirement and not requirement.startswith("#"):
                    requirements.append(requirement)
    return requirements


setup(
    name="pkgnet",
    version="0.1",
    description="",
    url="",
    author="",
    author_email="",
    install_requires=load_requirements(INSTALL_REQUIREMENTS_FILE),
    license="BSD",
    packages=["pkgnet"],
    zip_safe=False,
)
