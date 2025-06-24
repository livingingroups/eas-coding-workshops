
tinyplot(
  ~ cyl|vs,
  data = mtcars,
  facet=~vs,
  type = "barplot",
  beside = TRUE,
  fill = 0.2
)

tinyplot(~ cyl | vs, data = mtcars, type = "barplot", beside = TRUE)

tinyplot(
  ~rep('', nrow(mtcars))|as.factor(vs),
  facet = ~as.factor(cyl),
  data = mtcars,
  type = "barplot",
  xlab = '',
  beside = TRUE
)

mycars <- mtcars
mycars$vs <- as.factor(mtcars$vs)
mycars$cyl <- as.factor(mtcars$cyl)
mycars$gear <- as.factor(mtcars$gear)
mycars$placeholder <- 1

mycars <- mtcars
mycars$cyl <- as.factor(mtcars$cyl)
tinyplot(
  ~cyl,
  data = mycars,
  type = "barplot",
  beside = TRUE
  ,xlevels = levels(mycars$cyl)[3:1]
)

tinyplot(
  ~cyl,
  data = mtcars,
  type = "barplot",
  fun = function(x) mean(x) + 100,
  beside = TRUE
)

#  ,xlevels = levels(factor(mycars$cyl))[3:1]

tinyplot(
  ~cyl,
  data = mtcars,
  type = "barplot",
  beside = TRUE
  ,xlevels = 3:1 
)

tinyplot(
  ~placeholder|vs,
  facet = ~cyl,
  data = mycars,
  type = "barplot",
  beside = TRUE
)
tinyplot(
  ~cyl | vs + gear,
  data = mycars,
  facet = ~gear,
  fill = as.integer(mycars$cyl), 
  type = "barplot",
  beside = TRUE
)


tinyplot(
  ~placeholder|vs,
  facet = ~cyl,
  data = mycars,
  type = "barplot",
  beside = TRUE
  ,xlevels = 1:3
)

tinyplot(
  ~1|as.factor(vs):as.factor(cyl),
  facet = ~as.factor(cyl),
  #fill = ~as.factor(vs),
  data = mtcars,
  type = "barplot",
  xlab = '',
  beside = TRUE
)

aq = transform(
  airquality,
  Month = factor(Month, labels = month.abb[unique(Month)])
)

my_f <- formula(Temp ~ 1 | Month + Day)

tinyplot(
  Temp ~ 1 | Month + Day,
  data = aq,
  col = ~Day,
  pch = 16,
  cex = 2,
  alpha = 0.3
)

tinyplot(
  ~cyl|vs,
  facet = ~cyl,
  data = mtcars,
  fill = c(2,3),
  type = "barplot",
  beside = TRUE
)

par(mfrow = c(2, 2))
for(cyl_val in unique(mtcars$cyl)){
  barplot(table(mtcars[which(mtcars$cyl == cyl_val), 'vs']),, main = paste0('cyl = ', cyl_val))

}
par(mfrow = c(1, 1))

plot.new()


mega_dt[,
  .(
   cnt = length(unique(Ind) )
  ),
  by = .(name.q, name.emote)
]

library(txtplot)
x <- factor(c("orange", "orange", "red", "green", "green", "red",
             "yellow", "purple", "purple", "orange"))

x <- factor(mega_dt$emote, levels = c("🤔", "🛠️", "🤯", "🥱", "😵‍💫"))

x <- factor(mega_dt$React, levels = c('i', 'u', 'w', 'b', 'c'))

txtbarchart(x, pch = levels(x), height = 40)
as.character(sort(x))

txtbarchart(x)

stars(mtcars[, 1:7], key.loc = c(14, 2),
      main = "Motor Trend Cars : stars(*, full = F)", full = TRUE)

stars(mtcars[, 1:7], locations = c(0, 0), radius = FALSE,
      key.loc = c(0, 0), main = "Motor Trend Cars", lty = 2)

dim(dc_dt)
stars(dc_dt[1,2:6], locations = c(0,0), key.loc = c(0,0), radius = FALSE)

stars(dc_dt[1:2,2:6], locations = c(0,0), key.loc = c(0,0))

N <- nrow(mega_dt)

mega_dt[,
  .(
    emote_overall_pct = .N/N,
    emote_avg_score = .N/44
  ),
  by = emote
]

merge(
  # need crossjoin to add back 0s
  CJ(
    Q = unique(mega_dt$Q),
    emote = unique(mega_dt$emote)
  ),
  mega_dt[,
    .(
      cnt = .N
    ),
    by = .(emote, Q)
  ],
  by = c('emote', 'Q'),
  all.x = TRUE
)[,
  cnt := nafill(cnt, fill = 0)
][,
  .(
    emote_mean_cnt = mean(cnt),
    emote_max_cnt = max(cnt),
    emote_min_cnt = min(cnt),
    emote_sd_cnt = sd(cnt)
  ),
  by = emote
]

summary(dc_dt)
