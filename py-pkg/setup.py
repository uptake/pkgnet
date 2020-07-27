from pathlib import Path
import setuptools


with (Path(__file__).parent / "README.md").open("r") as fp:
    long_description = fp.read().strip()


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


setuptools.setup(
    name="pkgnet",
    version="0.1.0",
    author="",
    author_email="",
    description="Network analysis of the structure and dependencies of Python packages.",
    classifiers=[
        "Programming Language :: Python :: 3",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: BSD License",
        "Operating System :: OS Independent",
    ],
    install_requires=load_requirements(INSTALL_REQUIREMENTS_FILE),
    license="BSD 3-Clause License",
    long_description=long_description,
    long_description_content_type="text/markdown",
    packages=setuptools.find_packages(include=["pkgnet"]),
    url="https://github.com/uptake/pkgnet",
)
