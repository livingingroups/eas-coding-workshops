import csv
from datetime import datetime, timedelta
from os import path

DATA_DIR = './20240402-performance/data'

GPS_data = [i for i in csv.DictReader(open(path.join(DATA_DIR, 'input_optim.csv')))]

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