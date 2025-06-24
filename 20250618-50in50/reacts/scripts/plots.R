source('scripts/lib.R')
source('scripts/theme.R')
library(data.table)
library(tinyplot)

SAVE <- TRUE
dev_args <- getOption("vsc.dev.args")


raw_reacts <- fread('data/raw_reacts.csv')
raw_reacts <- raw_reacts[Q %in% 1:45,]
raw_reacts <- split_react(raw_reacts)

q_meta <- as.data.table(read.csv('data/q_meta.csv'))
q_meta <- fread('data/q_meta.csv', sep=';')
q_meta$Q <- 1:nrow(q_meta)

react_meta <- rbindlist(list(
  list(
    name = 'Interesting',
    description = 'Good to know.',
    emote = '🤔',
    letter = 'i'
  ),
  list(
    name = 'Useful',
    description = 'I will use this.',
    emote = '🛠️',
    letter = 'u'
  ),
  list(
    name = 'Confusing',
    description = 'What even is this?',
    emote = '😵‍💫',
    letter = 'c'
  ),
  list(
    name = 'Boring',
    description = 'Old news/Not relevant',
    emote = '🥱',
    letter = 'b'
  ),
  list(
    name = 'Wow',
    description = 'This will change my life.',
    emote = '🤯',
    letter = 'w'
  )
))

mega_dt <- merge(
  merge(
    raw_reacts,
    q_meta,
    by = 'Q',
  ),
  react_meta,
  by.x = 'React',
  by.y = 'letter',
  suffixes = c('.q', '.emote')
)


# Reaction by Q
# wide
dc_dt <- dcast(
    mega_dt,
    name.q ~ name.emote,
    length
)


if (SAVE) do.call(png, c(list(filename = 'plots/reacts-by-tip.png'), dev_args))
tinyplot::tinyplot(
  ~as.factor(apply_strwrap(name.q, 40)),
  facet = ~factor(name.emote
    , levels = c('Interesting', 'Useful', 'Wow', 'Boring', 'Confusing')
  ),
  type = 'barplot',
  beside=TRUE,
  data = mega_dt,
  flip = TRUE,
  ylab = 'Tip'
  , xlevels = apply_strwrap(unique(mega_dt$name.q), 40)[44:1]
)
if (SAVE) dev.off()

mega_dt[, placeholder := '']
tinyplot::tinyplot(
  ~placeholder|factor(name.emote),
  facet = ~factor(apply_strwrap(name.q)),
  type = 'barplot',
  beside=TRUE,
  data = mega_dt,
)


long_cnt <- mega_dt[,
  .(cnt = .N),
  by = .(emote, name.q, Q)
]
long_cnt[,placeholder :=1]
for (current_q in unique(mega_dt$Q)) {
  if(SAVE) png(paste0('plots/', current_q, '.png'))
  tinyplot::tinyplot(
    cnt~factor(emote, levels = c("😵‍💫", "🥱", "🤯", "🛠️", "🤔")),
    type = 'barplot',
    beside=TRUE,
    flip = TRUE,
    FUN = function(x) mean(x)*100/n_ind,
    data = long_cnt[Q == current_q,],
    main = apply_strwrap(paste0(
      'Reactions to ',
      unique(mega_dt[Q == current_q, name.q])
    ), 70),
    xlab = '',
    ylab = '%'
    , xaxt = 'n'
  )
  axis(2,cex.axis=2.3, labels = c("😵‍💫", "🥱", "🤯", "🛠️", "🤔"), at = 1:5)
  if(SAVE) dev.off()
}