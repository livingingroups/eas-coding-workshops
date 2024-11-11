# Setup

-   Clone repo or pull latest changes

-   Set working directory to `20241112-project-structure`

-   Install requirements

    ```         
    # Packages needed for workshop
    install.packages('devtools', 'validate', 'targets', 'tinytest', 'pkgKitten')

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
    -   code
        -   in this case multiple folders: `01-just-a-script`, `02-script-with-functions` etc.
        -   in general if you have a "R code" folder inside your project, you should name it `R`
    -   intermediates, in this case `saved-models`
    -   outputs, in this case `plots` . Could be broken up into separate "plots" and "results" folder, as recommended [here](#0).
-   **Working on EAS rstudio server**
    -   data folder should be on the data server (`EAS_shared`, `EAS_ind`, or `EAS_home`)
    -   code should *not* be on the data server, should be under source control (git)
    -   intermediates and outputs: up to you
-   **Avoiding committing your data** (unless you want to). If you have your `/data` folder inside your rstudio project folder and thus inside your git repo, but you don't want to actually track changes and push to github. Then, you can add `data` (or whatever the name of your data folder is) to the `.gitignore` file.
-   **Define paths once** Define each relevant folder (in this case, maybe just code and data folders) at the beginning of the script. Then use `file.path(...)` to put together the path (folder) and the filename like `file.path(DATA_FOLDER, 'my_data.csv')`. (`file.path('~', 'my-project', 'data', 'my-data.csv')` will result in `'~/my-project/data/my-data.csv'` on Linux/Mac and `'~\my-project\data\my-data.csv'` on Windows so it's safer than using `paste` for the same purpose.)

### Non-code structure example

#### Data Server + RStudio Server Workflow

```         
DATA SERVER
EAS_shared/YOUR_SPECIES/working/rawdata/your-field-season/
|- some_data.csv
|- more_data.csv

EAS_ind/YOU_USERNAME/your-analysis-results/
|- processed_data/
|- plots/
|- text-ouputs/

RSTUDIO SERVER
/home/top/YOUR_USERNAME
|- your-analysis <- root of git repo
    |- your_code.R
    |- another_script.R
```

In the code

```{r}
INPUT_DIR <- '~/EAS_shared/YOUR_SPECIES/working/rawdata/your-field-season/'
OUTPUT_DIR <- '~/EAS_ind/YOU_USERNAME/your-analysis-results/'
source('./another_script.R')
read.csv(file.path(INPUT_DIR, 'some_data.csv'))
...
write.csv(file.path(OUTPUT_DIR, 'processed_data', 'cleaned_data.csv'))
```

#### Local Workflow

```         
/home/YOUR_USERNAME/
|- YOUR_SPECIES/working/rawdata/your-field-season <- synced with filezilla
    |- some_data.csv
    |- more_data.csv
|- your-analysis-results <- synced with filezilla
    |- processed_data/
    |- plots/
    |- text-ouputs/
|- your-analysis <- synced with git
    |- your_code.R
    |- another_script.R
```

```{r}
# changed
INPUT_DIR <- '~/YOUR_SPECIES/working/rawdata/your-field-season/'
OUTPUT_DIR <- '~/your-analysis-results/'

# not changed
source('./another_script.R')
read.csv(file.path(INPUT_DIR, 'some_data.csv'))
...
write.csv(file.path(OUTPUT_DIR, 'processed_data', 'cleaned_data.csv'))
```

#### How to avoid changing 2 lines of code

In your .Rprofile on the rstudio server:

```         
EAS_SHARED_PATH <- '~/EAS_shared'
EAS_INV_PATH <- '~/EAS_ind'
```

In your .Rprofile locally:

```         
EAS_SHARED_PATH <- '~'
EAS_IND_PATH <- '~/..'
# ^ (only works if your username is the same on your local machine)
# otherwise, you'll need to slightly change your local folder structure above
```

R script:

```{r}
# changed
INPUT_DIR <- file.path(EAS_SHARED_PATH, 'YOUR_SPECIES/working/rawdata/your-field-season/')
OUTPUT_DIR <- file.path(EAS_IND_PATH, 'your-analysis-results/')
```

Once you get to the point of publishing your code beyond EAS audience, you will want to let the user chose what path they've put their (or your) data in. This will hopefully come after setting up your code into functions.

### 🛠️ [Code Sections](https://support.posit.co/hc/en-us/articles/200484568-Code-Folding-and-Sections-in-the-RStudio-IDE)

Adding at least 4 `#` to the end of the comment makes it a section heading. The number of `#` at the beginning determines the "level". For example:

```         

# H1

## H2

### H3
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

-   **Strategy to Transition** Options:
    -   Bottom up: start with small pieces of repeated code, make functions for those
    -   Top down: start by making one big function that you call at the end.
-   **Avoiding Breakage**
    -   You need a way to check that the final output of your script is unchanged.
    -   Having `validate` and `tinytest` checks sprinkled in will help detect problems before the end.
-   Review `list()` data structure as a way to return more than one value from a function.
-   **Start Documenting Now**
-   You can use `do.call` to call a function with a per-defined list of arguments
-   **Debugging Tools** This is a good stage to start testing out [Formal Debugging Tools](https://adv-r.hadley.nz/debugging.html)
    -   `browser`
    -   `traceback` start to be useful here
    -   breakpoints

### Debugging Demo

## Stage 3: Three File Workflow

### Problems it solves

When I'm writing my code, I do a lot of running and rerunning with a small part. It's hard to keep track of which code is left over from this process and which is part of my "real" script.

### :tools: Rmd

## Stage 4: Targets Workflow

### Problems it solves

My file with functions is getting really long. I want to break it into separate scripts, but then, I'd have to add "source()" everywhere.

I keep having to comment and uncomment things in my runner script, especially the parts that are taking a long time. Even with fewer variables to keep track of, it's still kind of hard to remember what needs to be refreshed. 

### How to transition

- Move `_lib` script into a folder called `R`
- Convert runner script into a _targets.R [Example here](https://books.ropensci.org/targets/walkthrough.html)
- Any functions that generate plots, you need to either save the plot an object (ggplot) or file [More Details Here](https://raps-with-r.dev/targets.html#a-pipeline-is-a-composition-of-pure-functions)
- Any functions that print important things (usually validation files) need to return the output or write to file. (`capture.output` can be useful for this)

### Test out in the workshop

```

tar_make(script = '04-targets/_targets.R')
tar_visnetwork(script = '04-targets/_targets.R')

tar_objects()
tar_load('mei_data')
tar_load('group_validation')
plot(group_validation)

tar_load_everything()

```

### Extra benefits

Targets has functionality that lets you run your code remotely, so if/when we grow beyond the rstudio server, this will be useful.

## Stage 5: Package (plus runner or targets)

### Problems it solves

### How to transition
From **either** stage 3 or stage 4,
- **Create package skeleton** `pkgKitten::kitten(name=YOUR_PACKAGE_NAME)`.
- **Add your functions** Move your _lib.R file from stage 3 into the newly created R folder OR replace the newly created R folder with your R folder from stage 4.
- **Add your tests** Move your tests.R file into `inst/tinytest` (if you want to use testthat, delete inst and tests folders and then follow testthat setup instructions). Remove any `source` or working directory things from that file.
- **Include your runner** There are several options:
   - The simplest option is to include in the git repo, but not the package, put it on the same level as DESCRIPTION. (This often makes the most sense for `_target.R`)
   - To include it with the package without modification, put it in the `inst` folder.
   - To make have it as a nice example to future users of your package, you can convert it into a vignette. To do this, you will need to include sample data.
   -  To in
- (opt) **Add sample data** This is if you want to publish some of your data as part of your package so that your users can easily access it without worrying about loading files. This will work similar to how `iris` and `mtcars` work in in base R. This is only appropriate for small data sets. [Full instructions here](https://r-pkgs.org/data.html)

### Handy Lines
```

devtools::load_all('05-package')
tinytest::run_test_dir('05-package/inst/tinytest/')

tar_make(script = '05-package/_targets.R')

devtools::document('05-package')
?load_group_homerange_data

```
   