# This works but is hard to read
# Let's write a better version!

process <- function(astring){
ls <- strsplit(astring, '\n')[[1]]; o <- data.frame(name='', type='', area=0)
for(idx in 1:length(ls)){
if(strsplit(ls[idx], ' ')[[1]][2] == 'square'){
a = as.numeric(substr(strsplit(ls[idx], '(', fixed=T)[[1]][2], 3,3)) * as.numeric(substr(strsplit(ls[idx], '(', fixed=T)[[1]][2], 3,3))
o[idx,] <- c(strsplit(ls[idx], ':')[[1]][1], strsplit(ls[idx], ' ')[[1]][2], a)
} else if(strsplit(ls[idx], ' ')[[1]][2] == 'circle'){
a = as.numeric(regmatches(ls[idx], regexpr('\\d', ls[idx]))) ** 2 * pi
o[idx,] <- c(strsplit(ls[idx], ':')[[1]][1], strsplit(ls[idx], ' ')[[1]][2], a)
} else if(strsplit(ls[idx], ' ')[[1]][2] == 'rectangle'){
eq = sub(',w=', '*', sub('\\).*', '', sub('.*\\(l=', '', ls[idx])))
a = eval(parse(text=eq)) # seriously, this is a bad idea
o[idx,] <- c(strsplit(ls[idx], ':')[[1]][1], strsplit(ls[idx], ' ')[[1]][2], a)
}
}
o$area <- as.numeric(o$area)
return(o)
}

#####################################
######### Example and test ##########
#####################################

shapes <- "firstshape: circle (r=3)
secondshape: square (l=5)
bluerect: rectangle (l=8,w=2)
secondsquare: square (l=1)
redrect: rectangle (l=45,w=100)"

actual_output <- process(shapes)

expected_output <- read.table(text ="name, type, area
firstshape, circle, 28.27433
secondshape, square, 25
bluerect, rectangle, 16
secondsquare, square, 1
redrect, rectangle, 4500", sep = ',', header=TRUE)


if (all(round(actual_output$area) == round(expected_output$area))){
  print('Working!')
} else {
  print('uh-oh, something broke')
}
