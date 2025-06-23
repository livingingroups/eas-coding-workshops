import os

import jinja2
import yaml

os.chdir('./20250618-50in50/')
env = jinja2.Environment(loader=jinja2.FileSystemLoader('./templates'))

tip_template = env.get_template('tip_template.qmd')
footer_template = env.get_template('footer_template.qmd')
header_template = env.get_template('header_template.qmd')


out_path = 'index.qmd'
y = yaml.safe_load(open('content/50in50.yaml'))

N = sum([len(y[s_key].keys()) for s_key in y.keys()])

n = 0
with open(out_path, 'w') as out_handle:
    with open('content/intro.qmd') as intro_handle:
        out_handle.writelines([l.format( **{
            'n': N
        }) for l in intro_handle])
    for s_key, s in y.items():
        with open('templates/section_template.rmd') as section_template:
            out_handle.writelines([l.format( **{
                'n_start': n + 1,
                'n_end': n + len(s.keys()) + 1,
                'section_name': s_key
            }) for l in section_template])
        for t_key, t in y[s_key].items():
            n += 1
            out_handle.write(tip_template.render(**t, **{
                'tip_name': t_key,
                'n': n,
                'footer': footer_template.render(**t, **{
                    'tip_name': t_key,
                    'n': n,
                }),
                'header': header_template.render(**t, **{
                    'tip_name': t_key,
                    'n': n,
                })
            }))
    with open('content/outro.md') as outro_handle:
        out_handle.writelines([l for l in outro_handle])