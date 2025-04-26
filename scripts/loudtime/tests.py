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
@patch('subprocess.Popen')
def test_speak_time_formats(mock_popen, time_str, interval, esp_args):
    """Test speaking time with different formats and intervals."""
    speak(time_str, interval)  # Call the 'speak' function
    mock_popen.assert_called_with(['espeak'] + esp_args)


@patch('time.time')
def test_get_time_format(mock_time):
    """Test the get_time function's format and behavior."""
    # Test with fixed timestamp for predictable results
    test_timestamp = 1609459200  # 2021-01-01 00:00:00
    mock_time.return_value = test_timestamp

    with patch('datetime.datetime') as mock_dt:
        mock_dt.fromtimestamp.return_value.isoformat.return_value = (
            "2021-01-01T00:00:02.008000"
        )

        assert get_time() == (test_timestamp, '00:00:02')


@patch('time.time')
@patch('subprocess.Popen')
@patch('time.sleep')
def test_main_normal_operation(mock_sleep, mock_popen, mock_time):
    """Test the main function's normal operation."""
    # Setup time sequence
    mock_time.side_effect = [
        1609459200,  # First call: 2021-01-01 00:00:00
        1609459201,  # Second call: 2021-01-01 00:00:01 (1s later)
    ]

    # Mock datetime for consistent time strings
    with patch('datetime.datetime') as mock_dt:
        mock_dt.fromtimestamp.side_effect = [
            type(
                'obj',
                (object,),
                {'isoformat': lambda: "2021-01-01T00:00:00.000000"},
            ),
            type(
                'obj',
                (object,),
                {'isoformat': lambda: "2021-01-01T00:00:01.000000"},
            ),
        ]

        # Setup to exit after one iteration
        def exit_after_iteration(*args, **kwargs):
            sys.exit(0)

        mock_sleep.side_effect = exit_after_iteration

        # Run main with default interval
        with patch.object(sys, 'argv', ['main.py', '1']):
            with pytest.raises(SystemExit):
                main()

        # Check if time was spoken properly
        mock_popen.assert_called_with(['espeak', 'twelve zero zero'])


@patch('time.time')
@patch('subprocess.Popen')
@patch('time.sleep')
def test_main_incorrect_time_increment(mock_sleep, mock_popen, mock_time):
    """Test the main function's handling of incorrect time increments."""
    # Setup time sequence with a time jump (3s instead of expected 1s)
    mock_time.side_effect = [
        1609459200,  # First call
        1609459200,  # Second call - when prevtime is set
        1609459203,  # Third call - when checking current time (3s jump)
    ]

    # Mock datetime for consistent time strings
    with patch('datetime.datetime') as mock_dt:
        mock_dt.fromtimestamp.side_effect = [
            type(
                'obj',
                (object,),
                {'isoformat': lambda: "2021-01-01T00:00:00.000000"},
            ),
            type(
                'obj',
                (object,),
                {'isoformat': lambda: "2021-01-01T00:00:00.000000"},
            ),
            type(
                'obj',
                (object,),
                {'isoformat': lambda: "2021-01-01T00:00:03.000000"},
            ),
        ]

        # Setup to exit after warning is generated
        def exit_after_warning(*args, **kwargs):
            sys.exit(0)

        mock_sleep.side_effect = exit_after_warning

        # Run main with specified interval of 1 second
        with patch.object(sys, 'argv', ['main.py', '1']):
            with pytest.raises(SystemExit):
                main()

        # Check if warning and time were spoken
        calls = mock_popen.call_args_list
        assert len(calls) >= 2
        assert calls[0][0][0] == ['espeak', 'INCORRECT TIME INCREMENT (3s)']
        assert calls[1][0][0] == ['espeak', 'twelve zero three']


@patch('subprocess.Popen')
def test_ones_constant(mock_popen):
    """Test that ONES constant is properly defined."""
    assert len(ONES) == 10
    assert ONES[0] == "zero"
    assert ONES[9] == "nine"

    # Test ONES is used in speak function
    speak("01:02:03", 30)
    mock_popen.assert_called_with(['espeak', 'one two three'])
