# Clear workspace and restart R before running
coarse_level_timing_and_memory <- function(expr) {
  gc_initial <- colSums(gc(reset = TRUE))
  timing <- system.time(expr)
  gc_final <- colSums(gc())
  names(timing) <- NULL
  names(gc_initial) <- NULL
  names(gc_final) <- NULL
  return(c(
    mem_used_baseline_mb = gc_initial[2],
    mem_used_diff_mb = gc_final[2] - gc_initial[2],
    mem_used_max_mb = gc_final[7],
    cpu_time = timing[1] + timing[2],
    elapsed_time = timing[3]
  ))
}

print(coarse_level_timing_and_memory(source('./your_script.R')))
