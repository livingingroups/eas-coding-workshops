from collections.abc import Iterable
from pprint import pp
from random import uniform, choice

from wordfreq import top_n_list
from Levenshtein import distance

def get_close_words(
        input_word: str,
        max_distance: int = 3,
        min_length: int = 3,
        word_library: Iterable[str] = top_n_list('en', 1000)
    ):
    close_words = [
        i for i in word_library 
        if distance(input_word, i) < max_distance 
        and len(i) > min_length
        and input_word != i
    ]
    return (word_library if len(close_words) == 0 else close_words)

def whisper(word: str, p_mistake: float = .5):
    return (choice(get_close_words(word)) if uniform(0,1) < p_mistake else word)

def simulate_single_game(seed_word: str, player_count: int):
    output = []
    current_word = seed_word
    for i in range(player_count):
        output.append(current_word)
        current_word = whisper(current_word)
    output.append(current_word)
    return output
        
def run(
        player_counts: Iterable[int] = range(6, 10),
        sims_per_player_count: int = 25,
        seed_word: str = 'shoes'
    ):
    all_sim_results = []
    for idx in range(sims_per_player_count): 
        for player_count in player_counts:
            all_sim_results.append({
                'index': idx,
                'n_players': player_count,
                'result': simulate_single_game(seed_word, player_count)
            })
    return all_sim_results

if __name__ == '__main__':
    pp(run())