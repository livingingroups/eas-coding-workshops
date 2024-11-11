# Setup

-   Clone repo or pull latest changes

-   Set working directory to `20241112-project-structure`

-   Install requirements

    ```         
    # Packages needed for workshop
    install.packages('devtools', 'validate', 'targets', 'tinytest')

    # Packages needed for example (only needed if you want to run the realistic example)
    install.packages(c("coda","mvtnorm","devtools","loo","dagitty", "dplyr", "RColorBrewer","lubridate"))
    # rethinking, cmdstanr
    install.packages("cmdstanr", repos = c('https://stan-dev.r-universe.dev', getOption("repos")))
    devtools::install_github("rmcelreath/rethinking")
    ```

# Intro

A lot of this is my own workflow/opinion, with some general principles mixed in. Please take what works for you and leave what doesn't behind.

# Stages

## Stage 1: Simple Script

### Tips

-   **Non-code project organization** Separate folders for:
    -   inputs, in this case called `data`
    -   code, in this case multiple folders:
        -   `just-a-script`
    -   intermediates, in this case `saved-models`
    -   outputs, in this case `plots` . Could be broken up into separate "plots" and "results" folder, as recommended [here](#0).
-   **Working on EAS rstudio server**
    -   data folder should be on the data server (`EAS_shared`, `EAS_ind`, or `EAS_home`)
    -   code should *not* be on the data server, should be under source control (git)
    -   intermediates and outputs: up to you
-   **Avoiding committing your data** (unless you want to). If you have your `/data` folder inside your rstudio project folder and thus inside your git repo, but you don't want to actually track changes and push to github. Then, you can add `data` (or whatever the name of your data folder is) to the `.gitignore` file.
-   **Define paths once** Define each relevant folder (in this case, maybe just code and data folders) at the beginning of the script. Then use `file.path(...)` to put together the path (folder) and the filename like `file.path(DATA_FOLDER, 'my_data.csv')`. (`file.path('~', 'my-project', 'data', 'my-data.csv')` will result in `'~/my-project/data/my-data.csv'` on Linux/Mac and `'~\my-project\data\my-data.csv'` on Windows so it's safer than using `paste` for the same purpose.)

### 🛠️ [Code Sections](https://support.posit.co/hc/en-us/articles/200484568-Code-Folding-and-Sections-in-the-RStudio-IDE)

Adding at least 4 `#` to the end of the comment makes it a section heading. The number of `#` at the beginning determines the "level". For example:


```         
# H1 ####
## H2 #####
### H3 #####
```

Results in:\
![](readme-images/clipboard-975315203.png)

(Also works to add to outline in Positron/VSCode.)

### 🛠️ `validate` package

In the previous, session we learned how to validate that your **code** is doing what you expect. However, this is different from checking whether your **data** is how you expect it. Even when you start your project and run things to see if it's "working" it's good to start making the distinction in your mind between these two concepts. You can start adding in `tinytest` calls to save your tests of code and `validate` calls to check your data.

[Lots of examples here](https://cran.r-project.org/web/packages/validate/vignettes/cookbook.html)

## Stage 2: Script with functions

### Problems it solves

I keep copying and pasting the same code in multiple places in my script. Then if I want to modify it, I have to do find and replace which doesn't always work.

My script is getting long enough that I have lots and lots of objects in my workspace and it's hard to remember what everything is. It's also hard to figure out what does or doesn't ened to get re-run.

### How it looks

Everything is still in one script, but the script as two parts. At the top, you define all the functions you use (some might call each other). At the bottom, the "runner" section of the script calls a few of these functions to kick off the process.

**OK, but how does this even help?** Before if you wanted to run only part of your script, either you highlight that part and try to be careful to highight the same portion each time, or you comment out big sections. Now, when you're only working on one section, you can just comment out the other parts in the "runner" section. Then when you run the whole script, the functions for those sections will still be defined, but not run. Likewise with plotting or anything you might want to run or not run.

### Tips

- **Strategy to Transition** Options:
   - Bottom up: start with small pieces of repeated code, make functions for those
   - Top down: start by making one big function that you call at the end. 
- **Avoiding Breakage** 
   - You need a way to check that the final output of your script is unchanged.
   - Having `validate` and `tinytest` checks sprinkled in will help detect problems before the end.
- Review `list()` data structure as a way to return more than one value from a function.
- You can use `do.call` to call a function with a per-defined list of arguments
- **Debugging Tools** This is a good stage to start testing out [Formal Debugging Tools](https://adv-r.hadley.nz/debugging.html)
  - `browser`
  - `traceback` start to be useful here
  - breakpoints

### Debugging Demo


## Three File Workflow

### Problems it solves

When I'm writing my code, I do a lot of running and rerunning with a small part. It's hard to keep track of which code is left over from this process and which is part of my "real" script.


### :tools: Rmd

### :tools: targets

## Package

### Problems it solves

My file with functions is getting really long. I want to break it into separate scripts, but then, I'd have to add "source()" everywhere.

