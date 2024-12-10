# pytest and pytest-mock are not explicitly imported but needed for this script
from unittest.mock import Mock, call, ANY

from simulation import whisper, simulate_single_game

def test_whisper(mocker):
    close_words = ['from', 'group', 'stop', 'cool']
    
    mock_uniform = Mock(return_value = .6)
    mocker.patch('simulation.uniform', mock_uniform)
    assert whisper('crop', p_mistake = .5) == 'crop'
    mock_uniform.assert_called_once()

    mock_uniform = Mock(return_value = .2)
    mocker.patch('simulation.uniform', mock_uniform)
    assert whisper('crop', p_mistake = .5) in close_words
    mock_uniform.assert_called_once()


def test_sim_single_game(mocker):
    # Seed: group
    # 1st whisper 
    #   uniform() returns 1
    #   choice not called
    # 2nd whisper
    #    uniform() returns 1 
    #    choice not called
    # 3rd whisper
    #    uniform() returns 0 
    #    choice('group') returns 'grump'
    # 4th whisper
    #    uniform() returns 0 
    #    choice('grump') returns 'goopy'

    mock_uniform = Mock(side_effect = [1, 1, 0, 0])
    mocker.patch('simulation.uniform', mock_uniform)

    mock_choice = Mock(side_effect = ['grump', 'goopy'])
    mocker.patch('simulation.choice', mock_choice)

    # actual run
    game_result = simulate_single_game('group', 4)

    assert game_result == ['group', 'group', 'group', 'grump', 'goopy']
    mock_uniform.assert_has_calls([call(0,1)]*4)
    mock_choice.assert_has_calls([call(ANY)]*2)
