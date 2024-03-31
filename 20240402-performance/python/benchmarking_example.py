import copy
import csv
from datetime import datetime, timedelta
from os import path
import timeit

import numpy as np
import pandas as pd

#region TestingTools

def benchmark(expr_list, n, setup, globals):
    times = [
        timeit.Timer(expr, setup, globals=globals).repeat(repeat = n, number = 1)
        for expr in expr_list
    ]
    return(pd.DataFrame({
        'expr': expr_list,
        'min': [min(l) for l in times],
        'mean': [np.mean(l) for l in times],
        'max': [max(l) for l in times]

    }))
    
def deep_equal(expected_output, actual_output):
    return(all([
        all([
          e_row[k] == a_row[k]
          for k in set(e_row.keys()).union(set(a_row.keys()))
        ])
        for e_row, a_row
        in zip(expected_output, actual_output)
    ]))
    
#endregion

#region FunctionsToBenchmark

def orig(GPS_data):
    for row in GPS_data:
        row['X'] = row['']
        del row['']
        row['study.local.timestamp'] = datetime.strptime(row['study.local.timestamp'][0:19], '%Y-%m-%d %H:%M:%S')
        row['fix_id'] = 'NA'

    GPS_data = [x for x in sorted(GPS_data, key=lambda x: (
        x['individual.local.identifier'],
        x['tag.local.identifier'],
        x['study.local.timestamp'],
    ))]

    id_counter = 1
    for i in range(len(GPS_data)):
        if GPS_data[i]['fix_id'] != 'NA':
          continue
        date_i = GPS_data[i]['date']
        tag_i = GPS_data[i]['tag.local.identifier']
        animal_i = GPS_data[i]['individual.local.identifier']
        id_indicies = [i]
        id_size = 0
        while (id_size != len(id_indicies)): 
            id_size = len(id_indicies)
            time_min_i = min([GPS_data[i]['study.local.timestamp'] for i in id_indicies])
            time_max_i = max([GPS_data[i]['study.local.timestamp'] for i in id_indicies])
            id_indicies = list(set(id_indicies + [
                i for i in range(len(GPS_data))
                if GPS_data[i]['date'] == date_i and
                GPS_data[i]['tag.local.identifier'] == tag_i and
                GPS_data[i]['individual.local.identifier'] == animal_i and
                GPS_data[i]['study.local.timestamp'] >= time_min_i - timedelta(seconds = 10) and
                GPS_data[i]['study.local.timestamp'] <= time_max_i + timedelta(seconds = 10)
            ]))
        for j in id_indicies:
            GPS_data[j]['fix_id'] = id_counter
        id_counter +=1
    return(GPS_data)

def do_less(GPS_data):
    for row in GPS_data:
        row['X'] = row['']
        del row['']
        row['study.local.timestamp'] = datetime.strptime(row['study.local.timestamp'][0:19], '%Y-%m-%d %H:%M:%S')

    GPS_data = [x for x in sorted(GPS_data, key=lambda x: (
        x['individual.local.identifier'],
        x['tag.local.identifier'],
        x['study.local.timestamp'],
    ))]
    
    enumerated_GPS_data = [i for i in enumerate(GPS_data)]

    id_counter = 1
    for i, row in enumerated_GPS_data:

        if 'fix_id' in row.keys():
          continue

        date_i = GPS_data[i]['date']
        tag_i = GPS_data[i]['tag.local.identifier']
        animal_i = GPS_data[i]['individual.local.identifier']

        candidate_indices = set([
            i for i, row in enumerated_GPS_data
            if row['date'] == date_i and
            row['tag.local.identifier'] == tag_i and
            row['individual.local.identifier'] == animal_i
        ])

        id_indicies = set([i])
        indices_added = True
        while indices_added: 
            indices_added = False
            time_min_i = min([GPS_data[i]['study.local.timestamp'] for i in id_indicies]) - timedelta(seconds = 10) 
            time_max_i = max([GPS_data[i]['study.local.timestamp'] for i in id_indicies]) + timedelta(seconds = 10) 
            newly_added = set([
                i for i in candidate_indices
                if GPS_data[i]['study.local.timestamp'] >= time_min_i and
                GPS_data[i]['study.local.timestamp'] <= time_max_i
            ])
            id_indicies.update(newly_added)
            candidate_indices.difference_update(newly_added)
            indices_added = bool(newly_added)
        for j in set(id_indicies):
            GPS_data[j]['fix_id'] = id_counter
        id_counter +=1
    return(GPS_data)

def with_pandas(GPS_data):
    df = pd.DataFrame.from_records(GPS_data).convert_dtypes()
    df['study.local.timestamp'] = pd.to_datetime(df['study.local.timestamp'], exact=False)
    df['X'] = df['']
    del df['']
    df = df.sort_values(by = [
        'individual.local.identifier',
        'tag.local.identifier',
        'study.local.timestamp',
    ])

    df['diff_previous'] = df['study.local.timestamp'] - df['study.local.timestamp'].shift()
    df['new_tag_study_day'] = (df['individual.local.identifier'].ne(df['individual.local.identifier'].shift()) |
      df['tag.local.identifier'].ne(df['tag.local.identifier'].shift()) |
      df['date'].ne(df['date'].shift())).fillna(True)
    df['is_first_obs_fix'] = ((df['diff_previous'] > timedelta(seconds=10)) | df['new_tag_study_day']).fillna(True)
    df.loc[df['is_first_obs_fix'], 'fix_id'] = range(1, sum(df['is_first_obs_fix'])+1)
    df['fix_id'] = df['fix_id'].ffill()

    del df['diff_previous']
    del df['new_tag_study_day']
    del df['is_first_obs_fix']

    return df.to_dict('records')


#endregion

#region TestingAndBenchmarking

#region Setup

DATA_DIR = './20240402-performance/data'

input_data = [i for i in csv.DictReader(open(path.join(DATA_DIR, 'input_optim.csv')))]
expected_output = [i for i in csv.DictReader(open(path.join(DATA_DIR, 'output_optim.csv')))]

for row in expected_output:
    row['study.local.timestamp'] = datetime.strptime(row['study.local.timestamp'][0:19], '%Y-%m-%d %H:%M:%S')
    row['fix_id'] = int(row['fix_id'])

#endregion

#region FunctionalTests

print(deep_equal(expected_output, orig(copy.deepcopy(input_data))))  
# print(deep_equal(expected_output, do_less(copy.deepcopy(input_data))))  
#print(deep_equal(expected_output, with_pandas(copy.deepcopy(input_data))))  

#endregion

#region Benchmarks
print(benchmark(
    [
        'orig(input_data)'
        #,'do_less(input_data)'
        #,'with_pandas(input_data)'
    ],
    n=10,
    setup = "input_data = [i for i in csv.DictReader(open(path.join(DATA_DIR, 'input_optim.csv')))]",
    globals=globals()
))

#endregion

#endregion