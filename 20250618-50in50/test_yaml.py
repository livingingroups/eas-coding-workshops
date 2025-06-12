import jsonschema
import yaml

tip_schema = {
    'type': 'object',
    'required': ['who', 'problems', 'r', 'python'],
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
        'gif': {
            'oneOf': [
                {'type': 'string'},
                {
                    'type': 'object',
                    'properties': {
                        'python': {'type': 'string'},
                        'r': {'type': 'string'},
                    }
                }
            ]
        },
        'script': {
            'oneOf': [
                {'type': 'string'},
                {
                    'type': 'object',
                    'properties': {
                        'python': {'type': 'string'},
                        'r': {'type': 'string'},
                    }
                }
            ]
        },
        'text': {'type': 'string'},
        'extratip': {'type': 'string'}
    }
}

y = yaml.safe_load(open('20250618-50in50/50in50.yaml'))

n = 0 

for s_key in y.keys():
    for t_key in y[s_key].keys():
        t = y[s_key][t_key]
        jsonschema.validate(t, tip_schema)
        assert(t.keys() <= {
            'who',
            'problems',
            'python',
            'r',
            'gif',
            'script',
            'text',
            'extratip'
        })
    print(s_key, ': ',len(y[s_key]))
    n += len(y[s_key])
    
print(n)

