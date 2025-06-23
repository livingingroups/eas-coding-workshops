import os

import jsonschema
import yaml

os.chdir('./20250618-50in50/')

tip_schema = {
    'type': 'object',
    'required': ['who', 'problems', 'r', 'python', 'links'],
    'anyOf': [
        {'required': ['text']},
        {'required': ['img']},
        {'required': ['code']},
    ],
    'properties': {
        'who': {
            'type': 'string',
         },
        'problems': {
            'type': 'array',
            'items': {'type': 'string'},
         },
        'python': {
            'type': 'boolean',
        },
        'r': {
            'type': 'boolean',
        },
        'img': {
            'type': 'array',
            'items': {'type': 'string'},
        },
        'code': {
            'type': 'object',
            'properties': {
                'python': {'type': 'string'},
                'r': {'type': 'string'},
            }
        },
        'links': {
            'type': 'array',
            'items': {'type': 'string'}
        },
        'citation': {'type': 'string'},
        'text': {'type': 'string'},
        'extratip': {'type': 'string'}
    },
    'additionalProperties': False
}

y = yaml.safe_load(open('content/50in50.yaml'))

n = 0 

for s_key in y.keys():
    for t_key in y[s_key].keys():
        t = y[s_key][t_key]
        jsonschema.validate(t, tip_schema)
        assert all([os.path.exists(os.path.join('img', f)) for f in t.get('img', [])]), t.get('img', [])
    print(s_key, ': ',len(y[s_key]))
    n += len(y[s_key])
    
print(n)


d = {k:len(v) for k, v in y.items()}

sum([i for i in d.values()][0:4])
