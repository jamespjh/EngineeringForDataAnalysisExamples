#!/usr/bin/env python

from distutils.core import setup

setup(name='dataeng',
      version='1.0',
      description='Python code for the Data Engineering Course Example',
      author='James Hetherington',
      author_email='j.hetherington@ucl.ac.uk',
      url='TBC',
      packages=['dataeng'],
      entry_points={'console_scripts': ['build-index = dataeng.gather:parse_index_entry']}
     )