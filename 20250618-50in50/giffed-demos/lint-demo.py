## BAD
m=   .5;x=range(1,
                
                
                
11);b=8
y =  [
m        *xi+           b
         for
xi
in 
         x]

## BETTER
m = .5
x = range(1, 11)
b = 8
y =  [m * xi + b for xi in x]
