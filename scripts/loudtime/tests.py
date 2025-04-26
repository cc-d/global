import pytest
from unittest.mock import patch, call

import sys
from datetime import datetime

# Import directly from the module
from main import two_word, speak, get_time, main, ONES, subprocess, time

# Test data constants
SAMPLE_TEXT = "Test speech"
SAMPLE_TIME = "10:30:45"
DEFAULT_INTERVAL = 1

# Define a dataclass for common datetime constants


DATA = (
    (
        1609459200,
        "2021-01-01T00:00:02.008000",
        "00:00:02",
        "twelve zero two",
        "twelve zero",
    ),
    (
        1609459200 + 39600 + ((53 * 60) + 17),
        "2021-01-01T11:53:17.003120",
        "11:53:17",
        "eleven fifty three sixteen",
        "eleven fifty three",
    ),
    (
        1609470000 + 10800 + ((7 * 60) + 53),
        "03:07:53",
        "2021-01-01T03:07:53.000017",
        "three seven fifty three",
        "three seven",
    ),
)


@patch('subprocess.Popen')
def test_speak_regular_text(mock_popen):
    """Test speaking regular text."""
    speak(SAMPLE_TEXT)
    mock_popen.assert_called_once_with(['espeak', SAMPLE_TEXT])


@pytest.mark.parametrize(
    'time_str, interval, esp_args',
    [
        (DATA[0][2], 30, ['two thirty four fifty six']),
        (DATA[1][2], 30, ['twelve fifteen thirty']),
        (DATA[2][2], 90, ['thirty four fifty six']),
        (SAMPLE_TEXT, None, [SAMPLE_TEXT, '-v', 'en-us']),
    ],
)