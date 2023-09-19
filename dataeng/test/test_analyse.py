from ..analysis import *

import pytest
import os

def test_can_analyse_file():
    fixture = os.path.join(os.path.dirname(__file__),
        'fixtures','collection',
        '99442.zip')
    result = analyse_file(fixture, 'arms')
    assert result[0] == "1851"
    assert result[1] == 9


def test_can_analyse_collection():
    fixture = os.path.join(os.path.dirname(__file__),
        'fixtures','collection')
    result = analyse_collection(fixture, 'arms')
    assert result["1851"] == 9
    assert result["1852"] == 79