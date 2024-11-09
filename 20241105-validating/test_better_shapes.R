# Import testing library and file with functions to test
library(tinytest)
source('better_shapes.R')

# Testing entire process() function

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


expect_equal(actual_output$area, expected_output$area, tolerance = .0001)

# Test parsing part only

expect_equal(
  parse_shape_definition_line("redrect: rectangle (l=45,w=100)"),
  list(
    shape_name = 'redrect',
    shape_type='rectangle',
    params = list(
      l = 45,
      w = 100
    )
  )
)


expect_equal(
  parse_shape_definition_line("firsttriangleever: triangle (a=2, b=3, c=3)"),
  list(
    shape_name = 'firsttriangleever',
    shape_type='triangle',
    params = list(
      a=2,
      b=3,
      c=3
    )
  )
)