---
editor_options: 
  markdown: 
    wrap: 72
---

# Overview

Agenda

1.  Conceptual Background and Preparation
2.  What's the problem?
3.  Where in my code is the problem?
4.  How can I fix it?
5.  Did that actually work?

*Goal*: Optimize the trade-off between your human time and compute
time/resources.

*Anti-Goal*: Make every part of your code run as fast as possible.

This week, there will not be hands on exercises, instead we'll cover a
lot of ground conceptually on performance optimization. You'll end up
with a toolbox how to improve your program's performance with a jumping
off point to learn how to use each tool.

If there's an area where you want to go deeper, let me know. We can do
hands-on follow ups sessions in small groups or individually.

# Conceptual Background

## What are likely sources of slowness?

Imagine your computer is like a restaurant. The CPU is like the staff
taking orders, and cooking stuff. Memory/RAM is like the counter space
where they work on preparing the food. Disk/ROM/Storage is like the
pantry and/or refrigerator where the food is stored longer time.

Possible issues:

-   CPU constraint: the restaurant is plenty big, but the staff has to
    do a lot of running around to take your order and prep all the food.
    -   Single process: It could be that you program is only using one
        CPU core. That's like having one employee running back and forth
        to take your order and cook.
-   Memory constrained: Memory is like the counterspace in the kitchen.
    It's really easy for the cooks to access while they're cooking. (vs
    disk which is like the pantry)
    -   Swap: When your system runs out of memory, it will use disc for
        the overflow. This is is called swap. This is way slower than
        regular memory, kind of like running out of counterspace and
        putting ingredients, bowls, and pots in any space available
        including the pantry.
-   IO constrained: If your program does a lot of reading and writing
    from storage, this can cause it to be slow especially if you reach
    the limits of how fast you can write and retrieve things from disk.
    This is like having the restaurant employees constantly running back
    and forth from the kitchen to the pantry and path in between getting
    congested.
-   Latency to external services: This is like the kitchen ordering
    supplies to be delivered immediately from another establishment. If
    this takes a long time, making your kitchen more efficient won't
    help much in completing the dish faster.
    -   Calling an API
    -   Data Server

## How does time/resource usage scale with more data?

(To learn more about this, search "Big O Notation")

Some posibilities:

-   Constant = 10x the data -\> exact same compute time/memory
-   Linearly = 10x the data -\> 10x the compute time/memory
-   Quadratically = 10x the data -\> 100x the compute time/memory
-   Exponentially = 10x the data -\> 10,000,000,000 the compute
    time/memory

You can determine this

-   Theoretically - by thinking through what your program is doing
-   Empirically - by testing your code with multiple sizes of input data

Also, consider that because your program has multiple components, it may
scale differently at different regions of data size. For example, if the
program's start-up cost is high relative to the incremental cost, it my
technically be scaling linearly, but practically constant. Another
example, some libraries function differently with different data sizes.
With higher data sizes, doing some heavier start-up calculation lower
incremental cost.

## Setting out your workbench

To evaluate and tinker with you're program, you'll want to lay it out
such that you can subject it to scientificish tests. You want to be able
to:

-   run the program a consistent way without extraneous variables.
    -   This usually means having a script that is built out such that
        you can clear your workspace, restart R, run your script and it
        will have the same outcome every time.
    -   No extraneous workspace variables impacting your script.
    -   Past runs don't impact the current run.
-   run your program on a subset of data so that you can realistically
    rerun it many times to evaluate.
    -   still should be enough so that the the "long parts" of th subset
        are the same as the full dataset.
    -   my ideal is usually \~.5 sec.
-   evaluate based on the output from the subset whether the program is
    doing what it's supposed to be doing.
    -   Ideally, this evaluation should be automatic.
    -   We covered this last week.

# What's the problem?

Is your program hitting system level resource constraints?

More specifically:

-   When I run my program on my full dataset, will it be memory
    constrained?
-   When my program is not memory constrained, will runtime be driven by
    CPU time or something else? (usually Network or Storage)

## Q&D with system-level monitoring

A very coarse, but still useful starting point is to run your script on
your full dataset (with some print statements to track where you are).
Simultaneously, monitor the process-level resource usage with Task
Manager (Windows), Activity Monitor (Mac), or `top`/`htop` Terminal
commands (\*nix based systems including Linux and Mac). R users should
also be aware of [Rstudio Memory
Widget](https://support.posit.co/hc/en-us/articles/1500005616261-Understanding-Memory-Usage-in-the-RStudio-IDE),
but this is more useful for point in time than dynamic monitoring.

Try to evaluate:

-   How much time elapses as you progress through each part of the
    program (or where do you get "stuck")?
-   Is the program limited to one CPU core, or using multiple? (Usually
    usage is in % of 1 core so 200% = 2 cores.)
-   Does it seem to be using very little CPU (much less than 100%)?
-   Is the amount of memory growing as the program progresses or staying
    constant?
-   If it's growing, at what rate?
-   How does the absolute amount of memory compare to the amount
    available?

## Quantifying the Issue - CPU Time, Elapsed Time, and Memory

### Will my program be memory constrained?

Meaning....will it use close to or more than the available memory?

#### Measuring in R

The `gc` function causes R to "give back" to the operating system any
memory that was used by objects that are now deleted. R runs this
function automatically from time to time, so usually, we don't need need
to worry about this. (BTW - Using functions is a good way to tell R when
variables aren't needed anymore without explicitly `rm()`ing them or
clearing your whole workspace.)

When you run `gc` manually, it lets us know how much memory R is
currently using. It also has a record of the maximum amount of memory
used since you last reset it. We can use this to get the max memory used
by our program like this:

``` r

gc(reset=TRUE) # output of this will give us a baseline

x <- rnorm(10e6)

gc() # Output of this can show us the size of our program's leftovers, and max used.
```

`used` = currently in use `gc trigger` = not well documented, based on
[this
thread](https://stat.ethz.ch/pipermail/r-help/2005-June/073341.html) the
threshold at which gc is run automatically. `max used` = max used since
last call of `gc(reset=TRUE)`

We don't care about the difference between Ncells and Vcells so we can
just consider the sum of each column.

#### Demo: Exploring gc() examples

#### Measuring in python

The `gc` function in python does not report memory usage. There's
another library
[memory_profiler](https://github.com/pythonprofilers/memory_profiler?tab=readme-ov-file#api)
that you can use. This works by sampling memory usage at a given
interval.

You can check how much memory the current python process is using with
`memory_usage(-1)`. By default, this will give you 5 samples .2 seconds
apart. If you want to profile a function, you can do that like
`memory_usage((my_function, args, kwargs))` where `args` is a list of
positional arguments and `kwargs` is a dictionary of keyword arguments.
Result is in MB.

Here's how you would check how much memory is used for numpy to genarate
10\^6 random numbers

``` python
from memory_profiler import memory_usage
import numpy as np


baseline_mem_usage = memory_usage(-1, timeout=.1)[0]
max_mem_usage = max(memory_usage(
    proc=(np.random.normal, [], {'size': int(10e6)}),
    interval = .001
))

print({
    'baseline': baseline_mem_usage,
    'max': max_mem_usage
})
```

See [this
note](https://github.com/pythonprofilers/memory_profiler?tab=readme-ov-file#tracking-forked-child-processes)
for multiprocessing.

#### Extracting insight

We want to look at "max used" from while our program was running (reset
before starting), and extrapolating what it would be like with more
data. This will be informed by "used" at the beginning. For example, if
the program scales linearly with more data, this will be approximately
equal to the intercept.

### Is my program CPU Constrained?

#### Measuring in R

To measure run time and CPU usage, call your program inside the
`system.time` function.

``` r
system.time(source('your_script.R'))
```

For example,

``` r
system.time(lapply(rep(1000, 1000), runif))
system.time(Sys.sleep(5))
```

<https://psutil.readthedocs.io/en/latest/#psutil.Process.cpu_times>

All these values are in seconds.

`elapsed` is the wall clock time, as in the actual amount of time it
took your program to run. It's equivalent to:

``` r
start_time <- Sys.time() # This function tells you current date and time
## run your program here
stop_time <- Sys.time()
elapsed <- stop_time - start_time
```

`user` and `system` represent two different types of CPU usage. Right
now, we don't care too much about the distinction.
[Here](https://stackoverflow.com/questions/556405/what-do-real-user-and-sys-mean-in-the-output-of-time1)'s
the explanation if you're curious. We care about the sum.

#### Timing in python

python offers functions for a few different types of time.

-   `time.time()` is wall clock
-   `time.perf_counter()` excludes sleep but still more or less measures
    elapsed time
-   `time.process_time()` is user + system as above

`timit` offers functionality to run your code and capture starting and
ending with the specified function.

``` python
import time
import timeit

print({
'elapsed': timeit.timeit(
    stmt = 'np.random.normal(size = int(10e6))',
    setup = 'import numpy as np',
    timer = time.perf_counter,
    # only run the function once
    number = 1
  ),
'process': timeit.timeit(
    stmt = 'np.random.normal(size = int(10e6))',
    setup = 'import numpy as np',
    timer = time.process_time,
    number = 1
  )
})
```

Running timeit is equivalent to

``` python
import time

t1 = time.perf_counter()
# your program
t2 = time.perf_counter()

print(t1 - t2)
```

#### Extracting insights

`elapsed >> user + system` means that a bottleneck on one CPU thread is
*not* what's making your script take a long time. There's lots of time
when the CPU is sitting around waiting for...something.

Silly example:

-   R: `system.time(browser())`
-   python: `timeit.timeit('import pdb; pdb.set_trace()', number=1)`

Some possibilities: - An external resource: some kind of networked
(not-on-your-computer) resource. For example, if your script is
downloading data from the internet or pulling files from the
dataserver. - Child process to complete: these tools are only measuring
CPU usage of the parent process. It could be waiting for its children -
In python, you can look at cpu usage of child processes using
`psutil`. - In R, in theory, `system.time()[4:5]` should show cpu usage
of child processes, but I have not found this to be the case in
practice. So far, I haven't found the reason or an alternative. - Your
harddrive (I/O limitation): Another (less common) possibility...if your
program is reading and writing a lot of files from your hard drive, the
hard drive could be the thing the cpu is waiting of.

`elapsed < user + system` means that during the time your program is
running, on average more than one CPU is running.

### Napkin Math

Once you've collected this data, you can ask our initial questions.

-   When I run my program on my full dataset, will it be memory
    constrained?
-   When my program is not memory constrained, will runtime be driven by
    CPU time or something else?

At this point, you may want to run these metric on a couple different
data set sizes to check your assumptions about how your program will
react to more data. It may be helpful to note that the output of gc is a
matrix and the output of sys.time can be treated as a vector so you can
write a program that run different scenarios and save instead of
printing the output if you so choose.

Function for running them together (created this quickly, so it may have
bugs.)

``` r
coarse_level_timing_and_memory <- function(expr) {
  gc_initial <- colSums(gc(reset = TRUE))
  timing <- system.time(expr)
  gc_final <- colSums(gc())
  names(timing) <- NULL
  names(gc_initial) <- NULL
  names(gc_final) <- NULL
  return(c(
    mem_used_diff_mb = gc_final[2] - gc_initial[2],
    mem_used_max_mb = gc_final[7],
    cpu_time = timing[1] + timing[2],
    elapsed_time = timing[3]
  ))
}

print(coarse_level_timing_and_memory(source('./your_script.R')))
```

``` python
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
    }
```

## Whiteboard activity: interpreting the output of gc and system.time

# Where is the bottleneck within my program?

## R + Not CPU or Memory Constrained

If you're in the `elapsed >> user + system` scenario, R's profiling
tools will not help you. (I'm not aware of any tools to profile based on
elapsed time.) Usually, there won't be too many places in your code
where you're interacting with external resources: websites, databases,
non-local file systems, or even the local filesystem for that matter. In
that case, you'll be able to manually identify what in the code is
taking time.

If you're unsure, you can sprinkle `Sys.time()` and/or `proc.time()`
throughout your code, saving the results, and compare how long various
sections take. These measurements can vary a lot based on external (to
R) factors, like what else is running on your machine and how long the
external resource takes to respond.

``` r
t0 <- Sys.time() # This function tells you current date and time
## part 1 of your program
t1 <- Sys.time()
# part 2 of your program
t2 <- Sys.time()
```

\^ if `t1 - t0 > t2 - t1` the the time suck is in the part 1 of your
program.

## Profiling

Based on the results of your initial exploration, you have some idea of
whether you need to focus on CPU usage, memory usage, or both.

### R - (CPU and/or Memory Constrained)

To identify the resource heavy parts of your R program, usually
RStudio's built-in profiler
[profvis](https://rstudio.github.io/profvis/) is all you need.

If you're worried about memory, look both for spike and for places where
memory is allocated (+, right side of the memory graph) but not
released.

Remember that (on Linux/Mac) `time` here is CPU time of the main R
process, not elapsed time. Time reported here will be less than elapsed
time in parts of the code where something other than computation (like
fetching a file) is happening. See the `Rprof` help page for details on
Windows.

This tool makes a distinction between code it thinks you wrote/care
about and package code. If you want to dig inside a particular package,
the documentation explains how to configure that.

### Demo: Profile Vis

### Python

Python has a couple options for profilers you can install:

-   [Austin](https://github.com/p403n1x87/austin)
-   [SnakeViz](https://jiffyclub.github.io/snakeviz/)

They each have a corresponding VSCode extension.

### Demo: Austin + VSCode

When you profile a script with Austin point-and-click through VSCode,
you chose Elapsed time, CPU time, or Memory to profile. (Select in the
bottom right.) You can go through them one by one.

It shows a flamegraph in the "Flamegraph" tag next to terminal. There's
no distinction between "your" functions and package functions so you
will see a lot of names you don't recognize. The width represents the
proportion of that resource used by that function.

### Stan

It's also possible to profile in Stan. More info here:
<https://mc-stan.org/cmdstanr/articles/profiling.html>

### Deeper with Profilers

They sample on some interval and check all the process that are running.

#### Whiteboard - Sampling/flame graph as histogram.

Point-and-click profile interface combines data collection and
visualization, but you can pull these apart by running the profiler
(Rprof, python cProfile, austin) to generate a report and tweak the
parameters used to profile. Then, you visualize that report with
profvis, snakeviz, Austin's VScode extension, or many others (at least
for python).

# How can I make it take less time?

-   [Really nice python-focused
    articles](https://pythonspeed.com/datascience/)
-   [Performance section of Advanced
    R](https://adv-r.hadley.nz/perf-improve.html)

## A Note Interpreted vs Compiled Languages

[An article with some nice
pictures](https://www.simplilearn.com/tutorials/python-tutorial/understand-the-workings-of-cpython)

Both R and python are designed in such a way that they can be converted
to byte code (what your compute actually reads) on a line by line basis.
This is great for usability, but not so great for efficiency. This is
kind of like a waiter who asks you what the first thing you'd like to
order is, then runs back to the kitchen to make it,. Then, when he
brings you your dish, he asks you for the second item you'd like to
order. Both R and python have functions take a bunch of processes you'd
like to implement together (or one process implemented on a bunch of
data) and let you send through all at once. Kind of like ordering a prix
fixe/meal deal.

In addition, when functions are written in C, they have more freedom but
also more flexibility to create an efficient implementation of a
specific task. In our analogy, if the cook knows at the start that he
has to make 10 of the same meal, he can do it more efficiently than if
he's only told to make the next burger once he's completed the last one.

Thus, when you use functions that are implemented efficiently in C
instead of writing the same functionality in R or python, you can get
the same task done in less time. In our analogy, you have the exact same
amount of restaurant staff and are ordering the exact same food. By
ordering it all at once, you save the staff the trouble of running back
and forth while also letting them spend their time in the kitchen more
efficiently.

## Ways to Reduce CPU Time

### Do Less

-   Critically evaluate your own code and whether each step is
    necessary. Are there steps happening in a loop that you really only
    need to do once?
-   Think about how the algorithm you're running scales with more data.
    Can you accomplish the same thing with a better scaling factor?
-   Step one layer into the function's you're calling. Generally, more
    flexible functions have some type checking etc. that takes up time.

Example: `stopifnot(expr)` vs `if(!expr) stop()`

(Performance section of Advanced R has some more practical examples.)

### Push Loops into Compiled Languages

Sometimes R users are told to "Vectorize" this is shorthand for saying
"use a function that iterates through your data in C rather than in R
(or python)".

``` r
v1 <- 1:10
v2 <- 12:21

for_loop_version <- function(){
  v3 <- numeric(10)
  for(i in 1:10){v3[i] <- v1[i] + v2[i]}
  return(v3)
}

vector_addition_version <- function(){return(v1 + v2)}

system.time(for_loop_version())
system.time(vector_addition_version())
```

``` python
import numpy as np
import time

def time_func(f):
    s = time.time()
    f()
    e = time.time()
    print(e - s)


v1 = np.arange(10)
v2 = np.arange(12, 22)

def for_loop_version():
    v3 = np.repeat(0, 10)
    for i in range(10):
        v3[i] = v1[i] + v2[i]
    return(v3)

    
def numpy_array_version():
    return(v1+v2)


# elapsed
time_func(for_loop_version)
time_func(numpy_array_version)
```

These more efficient functions are usually more picky about datatypes.
They leverage extra assumptions about inputs into more efficient ways of
doing things. For example, the `for_for_loop_version` above can be used
on any list of things that can be added together. In the vector/numpy
versions, `v1` and `v2` must have a consistent datatype.

Note that list comprehension (python) and lapply/sapply/etc. are more
concise, but computationally equivalent to a corresponding for loop.

Doing operations in data.table or numpy/pandas tend to be optimized in
c.

### Replace Inefficient Functions from Other Packages

For most basic operations, there are several packages that can do the
job. (For example, in R, there's often a base R way, a tidyverse way,
and one or more other packages that do simialr things.) Try them out and
see which one works fastest.

This may seem like an overwhelming amount of work, but remember that you
only need to do it for the portions of your code that you've identified
as a bottleneck.

I'll take this opportunity to plug data.table over tidyverse in R.
There's plenty of blogposts comparing the two with benchmarks. There's a
bit of a learning curve with dt, but IMO it's well worth it especially
if you consider the rest of your academic coding career. There's also a
library [tidydt](https://hope-data-science.github.io/tidydt/) that tries
to bring some of the efficiency of data.table with tidy-style code.

## Ways to Reduce Memory Usage

### Filter Early

If you're taking a subset of your data at some point in the script, do
that as early as possible so you only do your operations on the parts of
the data that you're going to keep.

### Clean Up Often

If you have one really long script in one environment, chances are
you'll end up with lots of variables sitting around that you don't need.
Those variables are taking up memory. This is particularly a problem if
you have intermediates variables that are the size of your data or
larger. There are a couple ways to combat this.

-   Use functions so that intermediates involved with a specific task go
    away when that task is complete.
-   Use `rm` (R) or `del` (python) to remove large objects that you
    don't need anymore. If you want the memory back immediately, you can
    run manually run `gc` (R) or `gc.collect()` (python)

### Use More Efficient (Less Flexible) Data Structures

There are many object structures you can use to store the same data.
They don't always take up the same memory, because they use different
amounts of metadata.

``` r
library(data.table)
library(tidyverse)
object.size(mtcars)
# 7208 bytes
object.size(array(mtcars))
# 3688 bytes
object.size(data.table(mtcars))
# 5928 bytes
object.size(tibble(mtcars))
# 4960 bytes
```

``` python
from pympler import asizeof
import numpy as np
import pandas as pd

seq = [i for i in range(100)]
asizeof.asizeof(seq)
# 4120
asizeof.asizeof(np.array(seq))
# 928
asizeof.asizeof(pd.Series(seq))
# 4768
```

### Write Intermediates to Disk, then Delete

You might be keeping around copies of your data to enable re-running
only certain portions or to troubleshoot. This is a great idea, but if
you keep all these intermediate versions as objects in R/python they can
fill up your memory. Consider writing them to disk (e.g. as a csv)
instead of keeping them around in memory.

## Reduce Elapsed Time with Parallelization

### Multiprocessing within R and Python

This will improve the ratio of CPU time to elapsed (real life) time.

Here are some reasons to think twice before doing this:

-   CPU/Elapsed time overhead: There is some overhead so total CPU time
    (time using cores \* number of cores) will go up. There is
    especially high overhead when new processes are spawned as opposed
    to forked. (Sometimes default, sometimes the only option depending
    on OS). In python, spawning processes involves a lot of data
    copying. It is possible for spawning processes to take more time
    than the process itself.

-   Memory Peak: In most cases, the peak memory used will go up so if
    your program is memory constrained, this will exacerbate the
    problem.

-   Hampering lower-level parallelization:

    -   From data.table docs: "`data.table` automatically switches to
        single threaded mode upon fork (the mechanism used by
        `parallel::mclapply` and the foreach package). Otherwise, nested
        parallelism would very likely overload your CPUs and result in
        much slower execution. "

    -   [Thread](https://github.com/numpy/numpy/issues/10145) from numpy
        github mentioning inefficiencies due to memory competition.

    -   [Article](https://superfastpython.com/numpy-processes-worse-performance/)
        empirically shows worse performance with numpy + multiprocessing
        (due to copying issue).

It's still useful in some cases, especially when you have a lot of
hardware at your disposal e.g. HPCs, RStudio Server.

Because of the overhead of starting processes, you'll want to have few
forkpoints and longer operations done within each process.

For example (pseudocode) :

```         
# yes
parallelfor(item in items):
  a(item)
  b(item)
  c(item)

# no
parallelfor(item in items):
  a(item)
parallelfor(item in items):
  b(item)
parallelfor(item in items):
  c(item)
```

How-to in R

-   [foreach](https://cran.r-project.org/web/packages/foreach/vignettes/foreach.html)
    vignette by the author

-   [foreach](https://privefl.github.io/blog/a-guide-to-parallelism-in-r/)
    tutorial with benchmarks

-   [mclapply/mcmapply](https://stat.ethz.ch/R-manual/R-devel/library/parallel/html/mclapply.html)
    docs

    -   Note: Per docs "It is *strongly discouraged* to use these
        functions in GUI ... environments" such as RStudio. I'm not sure
        if this guidance is still applicable with recent versions of
        RStudio. I have used these functions without crashes.

How-to in python

-   [Multi Threading](https://docs.python.org/3/library/threading.html)

    -   Lower overhead than multiprocessing.
    -   Important: "only one thread can execute Python code at once".
        This library is useful when you are in the situation of lots of
        elapsed time for the amount of CPU time. Other threads can
        execute code, while you're "waiting" for an external service.

-   [Multi
    Processing](https://docs.python.org/3/library/multiprocessing.html#module-multiprocessing)

    -   This approach is useful when you are CPU Bound but not memory
        bound.
    -   Worthwhile to learn the pros and cons of spawn, fork, and
        forkserver start methods. [Explained pretty well
        here.](https://stackoverflow.com/a/66113051)
    -   Reminder: `time.process_time()` will not include child
        processes. You'll need to use `psutil` to get these data.

### Use Libraries that Parallelize in Compiled Languages

Similar to how loops in compiled languages have less overhead. Using a
library that performs operations in a parallel fashion within C is more
efficient (in both CPU time and elapsed time) than spawning multiple
processes in R or python. `numpy` and `data.table` do this quite nicely.
If you're using this approach, you want to make sure that the library
you're using using the number of cores that you want it to. (Mac +
`data.table` this takes some extra steps.)

This is often more fruitful that doing the parallelization yourself.

More details on configuring `numpy` threading
[here](https://superfastpython.com/numpy-number-blas-threads/).

More details on configuring `data.table` threading
[here](https://search.r-project.org/CRAN/refmans/data.table/html/openmp-utils.html).

### Use and Configure Libraries to Leverage GPUs

GPUs can do some very specific tasks with a *very* high degree of
parallelization. The good news is that some of these very specific tasks
(e.g. matrix algebra) are useful for fitting models. The bad news is
it's not so simple to talk to a GPU from an interpreted language. The
underlying complied code needs to be written in a very specific way. It
varies by model and by language whether there is a package with GPU
support.

#### GPUs and R

Popular data processing libraries (tidyverse, data.table) do not have
GPU support. There is a package (I haven't used it)
[GPUmatrix](https://github.com/ceslobfer/GPUmatrix) that provides at
least the building blocks for GPU support.

If your underlying model is in Stan, there is a way to compile it to
leverage GPUs: <https://mc-stan.org/cmdstanr/articles/opencl.html>

#### GPUs and python

Major machine learning libraries pytorch and tensorflow (and therefore
models built on them) can leverage GPUs. There are is also a
numpy/scipy-like package [CuPy](https://cupy.dev/)

# Did it actually actually work?

-   [Comparison of Python Benchmark
    Tools](https://switowski.com/blog/how-to-benchmark-python-code/)

R benchmarking options:

-   [microbenchmark](https://cran.r-project.org/package=microbenchmark)

-   [bench](https://bench.r-lib.org/)

-   [tictoc](https://cran.r-project.org/web/packages/tictoc/index.html)

## Demo: Benchmarking
