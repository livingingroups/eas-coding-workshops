if(basename(getwd()) == 'tests') setwd('..')

# Import testing library and file with functions to test
library(testthat)
source('./code/better_shapes.R')