###
#  This is an improvement on shapes.R, not necessarily the best/only
#  way to complete the exercise
#  I've gone a bit overkill on documentation for demonstration purposes.
#  Also, both the for loops can be "simplified" with lapply
#  which would make the code more compact, but not necessarily more readable.
##


#' Parse a single line of shape definitions string into a shape definition
#'
#' @param shape_definition_line a string that defines a single shape
#' (see details of process function)
#' @return a list with elements shape_name, shape_type, and parameters:w
#' @example
#' parse_shape_definition_line("redrect: rectangle (l=45,w=100)")
#' returns list(
#'   shape_name = 'redrect',
#'   shape_type='rectangle',
#'   l = 45,
#'   w = 100
#' )
parse_shape_definition_line <- function(shape_definition_line){
  split_line <- unlist(strsplit(
    x = shape_definition_line,
    # this regex matches one or more of
    # colon, open parens, close parens, comma, or space
    # does *not* split on equals sign.
    split =  '[: \\(,\\)]+'
  ))

  # result is something like c('redrect', 'rectangle', 'l=45', 'w=100')
  params <- list()

  # start with the 3rd element
  for(param_string in split_line[3:length(split_line)]){
    # break apart param name and value
    split_param_string <- unlist(strsplit(param_string, '='))
    # e.g. parsed_line[["l"]] <- 45
    params[[split_param_string[1]]] <- as.numeric(split_param_string[2])
  }
  return(list(
    # e.g. redrect
    shape_name = split_line[1],
    # e.g. rectangle
    shape_type = split_line[2],
    params = params
  ))
}

#' Calculate shape area
#'
#' @param shape_type must be one of: 'square', 'circle', 'rectangle'
#' @param params list of paramters (see details of process function)
#'
#' @return single numeric value representing shape area
calculate_shape_area <- function(shape_type, params){
  if(shape_type == 'square'){
    area <- params$l ^ 2
  } else if(shape_type == 'rectangle'){
    area <- params$l * params$w
  } else if(shape_type == 'circle'){
    area <- params$r ^2 * pi
  }
  return(area)
}


#'Calculate Area of Shapes
#'
#'@param shape_definitions_string a string where each line defines a shape like
#'  `shape_name: shape_type (shape_params)`. (See Details)
#'
#'@return dataframe with columns: `name`, `type`, and `area` name and type
#'  coming from input definitions and area calculated based on params.
#'@export
#'
#'@details `shape_name` can be any alpha numeric string, but should not contain
#'whitespace or symbols `shape_type` must be one of square, circle, and
#'rectangle. `shape_params` must be comma separated `param_name=param_values`
#'Each shape has required shape params as follows: .
#'
#'.   - `square`: `l` (length)
#'.   - `rectangle`: `l` (length), `w` (width) .
#'.   - `circle`: `r` (radius)
process <- function(shape_definitions_string) {
  output_df <- data.frame()

  # split into lines
  for (line in unlist(strsplit(shape_definitions_string, '\n'))){

    # parse the line
    shape_definition <- parse_shape_definition_line(line)

    shape_name <- shape_definition$shape_name
    shape_type <- shape_definition$shape_type

    # calculate area
    area <- calculate_shape_area(
      shape_definition$shape_type,
      shape_definition$params
    )

    # append to dataframe
    output_df <- rbind(output_df,
          data.frame(
            shape_name = shape_name,
            shape_type = shape_type,
            area = area
    ))
  }
  return(output_df)
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
