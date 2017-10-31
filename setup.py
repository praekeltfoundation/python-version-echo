import codecs
import os
import re

from setuptools import setup, find_packages


HERE = os.path.abspath(os.path.dirname(__file__))


def read(*parts):  # Stolen from txacme
    with codecs.open(os.path.join(HERE, *parts), 'rb', 'utf-8') as f:
        return f.read()


def get_version(package):
    ver_file = read(os.path.join('src', package + '.py'))
    return re.search("__version__ = ['\"]([^'\"]+)['\"]", ver_file).group(1)


version = get_version('app')


setup(
    name="version_echo",
    version=version,
    url='',
    license='BSD',
    description='Version Echo Server',
    long_description=read('README.md'),
    author='Jason Paidoussi',
    author_email='jason@praekelt.org',
    packages=find_packages(where='src'),
    package_dir={'': 'src'},
    include_package_data=True,
    install_requires=[
    ],
    classifiers=[
        'Private :: Do Not Upload',
        'Development Status :: 3 - Alpha',
        'Programming Language :: Python',
    ],
)
