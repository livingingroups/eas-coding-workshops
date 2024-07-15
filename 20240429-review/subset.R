DATES <- c(
    '2014-02-03',
    '2014-02-04',
    '2014-03-14',
    '2014-03-15',
    '2014-04-07',
    '2014-04-08',
    '2014-04-14',
    '2014-04-15',
    '2014-05-01',
    '2014-05-02',
    '2014-06-14',
    '2014-08-11',
    '2014-08-12'
  )

bd <- read.csv("bab_dyad.csv")

write.csv(
  bd[which(substr(bd$local_timestamp, 1,10) %in% DATES) , ],
  'bab_dyad_subset.csv',
  row.names = FALSE
)


enc_df <- read.csv("enc_df.csv")
write.csv(
  enc_df[which(format(enc_df0$start_local_timestamp, format = '%Y-%m-%d') %in% DATES) , ],
  'enc_df_subset.csv',
  row.names = FALSE
)


