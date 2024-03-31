import time
from memory_profiler import memory_usage

def coarse_timing_and_mem(a_function, *args, **kwargs):
    baseline_mem_usage = memory_usage(-1, timeout=.1)[0]
    cpu_t1 = time.process_time()
    elapsed_t1 = time.perf_counter()
    max_mem_usage = max(memory_usage(
        proc=(a_function, args, kwargs),
        interval = .001
    ))
    cpu_t2 = time.process_time()
    elapsed_t2 = time.perf_counter()
    final_mem_usage = memory_usage(-1, timeout=.1)[0]
    return({
        'mem_used_baseline': baseline_mem_usage,
        # diff should always be zero, putting here for consistency with R version
        'mem_used_diff': final_mem_usage - baseline_mem_usage,
        'mem_used_max': max_mem_usage, 
        'cpu_time': cpu_t2 - cpu_t1,
        'elapsed_time': elapsed_t2 - elapsed_t1
    })
    
#import numpy as np
#coarse_timing_and_mem(np.random.normal, size=int(10e6))

