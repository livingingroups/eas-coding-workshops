# This works but is hard to read
# Let's write a better version!

import re
from math import pi

def process(astring):
    ls = astring.split('\n')
    o = {}
    for idx in range(len(ls)):
        if ls[idx].split(' ')[1] == 'square':
            a = float(ls[idx].split('(')[1][2])  * float(ls[idx].split('(')[1][2])
            o[ls[idx].split(':')[0]] = {'type': ls[idx].split(' ')[1], 'area': a}
        elif ls[idx].split(' ')[1] == 'circle':
            a = float(re.search('\\d', ls[idx]).group(0)) ** 2 * pi
            o[ls[idx].split(':')[0]] = {'type': ls[idx].split(' ')[1], 'area': a}
        elif ls[idx].split(' ')[1] == 'rectangle':
            eq = re.sub(',w=', '*', re.sub('\\).*', '', re.sub('.*\\(l=', '', ls[idx])))
            a = eval(eq) # seriously, this is a bad idea
            o[ls[idx].split(':')[0]] = {'type': ls[idx].split(' ')[1], 'area': a}
    for k in o.keys(): o[k]['area'] = float(o[k]['area'])
    return(o)

#####################################
######### Example and test ##########
#####################################

shapes = '''firstshape: circle (r=3)
secondshape: square (l=5)
bluerect: rectangle (l=8,w=2)
secondsquare: square (l=1)
redrect: rectangle (l=45,w=100)'''

actual_output = process(shapes)

expected_output = {
    "firstshape": {"type":"circle", "area": 28.27433},
    "secondshape": {"type":"square", "area": 25},
    "bluerect": {"type":"rectangle", "area": 16},
    "secondsquare": {"type":"square", "area": 1},
    "redrect": {"type":"rectangle", "area": 4500}
}

if all([
    round(expected_output[name]['area']) == round(actual_output[name]['area'])
    for name in expected_output.keys()
]):
    print('Working!')
else:
    print('uh-oh, something broke')
