library(yaml)
raw_yaml <- yaml.load_file('../content/50in50.yaml')

out <- list()

for (section_name in names(raw_yaml)) {
  for (tip_name in names(raw_yaml[[section_name]])) {
    tip <- raw_yaml[[section_name]][[tip_name]]
    has_img <- 'img' %in% names(tip)
    tip_meta <- list(
      name = tip_name,
      section_name = section_name,
      py = tip[['python']],
      r = tip[['r']],
      img = has_img,
      img_count = length(tip[['img']]),
      img_still = if (has_img) any(match(c('jpg', 'jpeg', 'png'), tolower(strsplit(tip[['img']], '.')))) else FALSE,
      img_gif = if (has_img) any(match(c('gif', 'mp4', 'mov'), tolower(strsplit(tip[['img']], '.')))) else FALSE,
      text = 'text' %in% names(tip),
      code_py = 'code' %in% names(tip) & 'python' %in% names(tip[['code']]),
      code_r = 'code' %in% names(tip) & 'r' %in% names(tip[['code']]),
      links_count = length(tip[['links']])
    )
    out <- c(out, list(tip_meta))
  }
}

write.table(do.call(rbind, out), 'data/q_meta.csv', sep = ';', row.names=FALSE)
