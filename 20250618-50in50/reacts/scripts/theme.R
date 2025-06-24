library(tinyplot)
library(extrafont)

dracula_colors <- c(
  red = '#FF5555',
  orange = '#FFB86C',
  yellow = '#F1FA8C',
  green = '#50FA7B',
  purple = '#BD93F9',
  blue = '#8BE9FD',
  pink = '#FF79C6'
)
dracula_bg <- '#282A36'
dracula_fg <- '#F8F8F2'
dracula_selection <- '#44475A'
dracula_comment <- '#6272A4'

theme_dark = tinytheme('minimal',
  #tinytheme = 'dracula',
  family = 'Ubuntu',
  bg = dracula_bg,
  fg = dracula_fg,
  col.xaxs = dracula_fg,
  col.yaxs = dracula_fg,
  col.lab = dracula_fg,
  col.main = dracula_fg,
  col.sub = dracula_fg,
  col.axis = dracula_fg,
  # facet.bg = "gray20",
  grid.col = dracula_selection,
  palette.qualitative = dracula_colors,
  palette.sequential = dracula_colors
)