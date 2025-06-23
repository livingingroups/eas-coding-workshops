library(logger)

log_threshold(DEBUG)

# do something
print('here are some details..............................................................')
# do something else
print('here is a summary ....')
# yet another thing 
print('even more details..............................................................')

library(logger)

log_threshold(DEBUG)

# do something
log_debug('here are some details..............................................................')
# do something else
log_info('here is a summary ....')
# yet another thing 
log_debug('even more details..............................................................')