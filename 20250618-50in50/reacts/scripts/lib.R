library(data.table)
split_react <- function(dt) {
  dt[, lapply(.SD, function(x) unlist(tstrsplit(x, "", fixed=TRUE))), by = .(Q,Ind, Note)
    ][!is.na(React)]
}
apply_strwrap <- function(x, width = 20, sep = '\n') {
  sapply(strwrap(x, width, simplify = FALSE), paste, collapse = sep)
}


testthat::expect_equal(
  split_react(data.table(
    Q = as.character(c(1,2)),
    Ind = 'A',
    Note = '',
    React = c('abc', 'b')
  )),
  data.table(
    Q = as.character(c(1,1,1,2)),
    Ind = 'A',
    Note = '',
    React = c('a', 'b', 'c', 'b')
  )
)

testthat::expect_equal(
  apply_strwrap(c(paste0(letters, collapse = ' '), paste0(LETTERS, collapse = ' '))),
  c(
    paste(
      paste0(letters[1:10], collapse = ' '),
      paste0(letters[11:20], collapse = ' '),
      paste0(letters[21:26], collapse = ' '),
      sep = '\n'
    ),
    paste(
      paste0(LETTERS[1:10], collapse = ' '),
      paste0(LETTERS[11:20], collapse = ' '),
      paste0(LETTERS[21:26], collapse = ' '),
      sep = '\n'
    )
  )
)


# dt <- data.table(
#     Q = c(1,2),
#     React = c('abc', 'b')
# )

# dt[,React := tstrsplit(React, ''), by = React]

# dt

# dt <- data.table(
#     Q = c(1,2),
#     React = c('abc', 'b')
# )

# dt[, lapply(.SD, function(x) unlist(tstrsplit(x, "", fixed=TRUE)))
#          ][!is.na(React)]

# dt[,React := unlist(tstrsplit(React, '', fixed=TRUE)), by = React]

# dt[,React := unlist(tstrsplit(React, '', fixed=TRUE)), by = React]

# x = c("abcde", "ghij", "klmnopq")
# strsplit(x, "", fixed=TRUE)
# tstrsplit(x, "", fixed=TRUE)
# tstrsplit(x, "", fixed=TRUE, fill="<NA>")

# unlist(tstrsplit(x, "", fixed=TRUE))
