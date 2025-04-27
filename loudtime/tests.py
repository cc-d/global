import pytest
from unittest.mock import patch, call

import sys
from datetime import datetime

# Import directly from the module
from .main import two_word, speak, get_time, main, ONES, subprocess, time, argv
from logfunc import logf

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
        "eleven fifty three seventeen",
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
        (DATA[0][2], 30, DATA[0][3].split()),
        (DATA[1][2], 30, DATA[1][3].split()),
        (DATA[2][2], 90, DATA[2][3].split()),
        (SAMPLE_TEXT, None, [SAMPLE_TEXT, '-v', 'en-us']),
    ],
)
@patch('subprocess.Popen')
@logf(use_print=True)
def test_speak_time_formats(mock_popen, time_str, interval, esp_args):
    """Test speaking time with different formats and intervals."""
    speak(time_str, interval)  # Call the 'speak' function
    print(esp_args, '#' * 333, ['espeak'] + esp_args)
    mock_popen.assert_called_with(['espeak'] + esp_args)


@patch('time.time')
@patch('subprocess.Popen')
@patch('time.sleep')
@pytest.mark.parametrize(
    'time_int, time_str, interval, esp_args',
    [
        (DATA[0][0], DATA[0][2], 30, DATA[0][3]),
        (DATA[0][0], DATA[1][2], 30, DATA[1][3]),
        (DATA[0][0], DATA[2][2], 90, DATA[2][3]),
        (DATA[1][0], SAMPLE_TEXT, None, [SAMPLE_TEXT, '-v', 'en-us']),
    ],
)
def test_main_normal_operation(
    mock_sleep, mock_popen, mock_time, time_int, time_str, interval, esp_args
):
    """Test the main function's normal operation."""
    # Setup time sequence
    # Mock datetime for consistent time strings
    mock_time.side_effect = time_int
    with patch('datetime.datetime') as mock_dt:
        mock_dt.fromtimestamp.side_effect = [
            type('obj', (object,), {'isoformat': lambda: time_str})
        ]

        # Setup to exit after one iteration
        def exit_after_iteration(*args, **kwargs):
            sys.exit(0)

        mock_sleep.side_effect = exit_after_iteration

        # Check if time was spoken properly
        mock_popen.assert_called_with(['espeak', esp_args.split()])


@patch('time.time')
@patch('subprocess.Popen')
@patch('time.sleep')
@pytest.mark.parametrize(
    'time_int, time_str, interval, esp_args',
    [
        (DATA[0][0], DATA[0][2], 30, DATA[0][3]),
        (DATA[0][0], DATA[0][2], 30, DATA[0][3]),
        (DATA[0][0], DATA[1][2], 30, DATA[2][3]),
        (DATA[0][0], DATA[2][2], 90, DATA[1][3]),
        (DATA[1][0], SAMPLE_TEXT, None, [SAMPLE_TEXT, '-v', 'en-us', 0]),
    ],
)
def test_main_incorrect_time_increment(
    mock_sleep,
    mock_popen,
    mock_time,
    time_int,
    time_str,
    interval,
    esp_args,
    time_inc_diff,
):
    """Test the main function's handling of incorrect time increments."""
    # Setup time sequence with a time jump (3s instead of expected 1s)
    mock_time.side_effect = time_int

    # Mock datetime for consistent time strings
    with patch('datetime.datetime') as mock_dt:
        mock_dt.fromtimestamp.side_effect = [
            type('obj', (object,), {'isoformat': lambda: time_str})
        ]

        # Setup to exit after warning is generated
        def exit_after_warning(*args, **kwargs):
            sys.exit(0)

        mock_sleep.side_effect = exit_after_warning

        # Check if warning and time were spoken
        calls = mock_popen.call_args_list
        assert len(calls) >= 2
        if time_inc_diff:
            assert calls[0][0][0] == [
                'espeak',
                'INCORRECT TIME INCREMENT (69s)',
            ]
        assert calls[1][0][0] == ['espeak', esp_args.split()]
