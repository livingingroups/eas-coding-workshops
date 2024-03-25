if(basename(getwd()) == 'tests') setwd('..')

# Import testing library and file with functions to test
library(testthat)
source('./R/better_shapes.R')
