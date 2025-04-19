from src.app import square
import pytest


testdata = [
    (1, 1),
    (2, 4),
    (3, 9),
    (4, 16),
    (5, 25)
]


@pytest.mark.parametrize('num,expected', testdata)
def test_quare(num, expected):
    assert square(num) == expected