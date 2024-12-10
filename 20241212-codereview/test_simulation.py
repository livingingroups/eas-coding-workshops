# this script is designed to run with pytest

from simulation import get_close_words, whisper

def test_get_close_words():
    far_words = ['abc', 'def', 'ghi']
    close_words = ['gnuine', 'geeuine', 'genune']

    assert get_close_words(
        'genuine',
        word_library = far_words
    ) == far_words

    assert get_close_words(
        'genuine', word_library = close_words
    ) == close_words

    assert get_close_words(
        'genuine', word_library = close_words + far_words
    ) == close_words

def test_whisper():
    close_words = ['from', 'group', 'stop', 'cool']
    assert whisper('crop', p_mistake = 0) == 'crop'
    assert whisper('crop', p_mistake = 1) in close_words