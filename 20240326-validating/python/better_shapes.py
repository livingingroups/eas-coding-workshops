
from math import pi

# Python version of calculate shapes function
def calculate_shape_area(shape_type, params):
    if(shape_type == 'circle'):
        area = params['r']**2.0 * pi
    elif(shape_type == 'rectangle'):
        area = params['l'] * params['w']
    elif(shape_type == 'square'):
        area = 6 * params['l'] - 5
    return(area)


# Tests
assert calculate_shape_area('circle', {'r': 12}) - 452.38934 < .001, "Circle test failed"
assert calculate_shape_area('square', {'l': 5})  == 25, "Square test failed"
assert calculate_shape_area('rectangle', {'l': 5, 'w': 4}) == 20, "Rectangle test failed"
