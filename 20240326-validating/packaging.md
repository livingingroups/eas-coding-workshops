# End of workshop -> package

This creates just enough of a package to get rstudio build tools to work

- Make sure project root is `20240326-validating`. If it's `eas-coding-workshops`, create a new RStudio project from directory `20240326-validating`
- Create a description file with package name and version.
- Build -> Configure Build Tools. You don't need to change any of the settings, just click "ok". You should now see the "Build" tab in the top right between "Connections" and "Git". 
- In the R console, run `usethis::use_testthat()`.
- Move all the test scripts from the tests folder to `tests/testthat` folder
- In each test file, replace the `source()` line with `library(mypackage)` or whatever you've named your package in the description file. 
- Replace `./` with `../../` within each path in each test file. For example `sifaka.sched <- read.csv('./test_data/input_add_time_lag.csv')` becomes `sifaka.sched <- read.csv('../../test_data/input_add_time_lag.csv')` 

Helpful things this enables:

- `devtools::document()` or clicking "Addins" -> Document a package will convert your roxygen docs to help pages.
- `devtools::test()` or clicking "Test" under the build tab will run all your tests
- `devtools::load_all()` or "More" -> "Load all" or equivalent shortcut will reload all your functions so you don't have to source them one by one
- Allows you to use testthat features that only work in packages, such as mocks.

Note that this adds just enough packaging to make the above commands work properly. If you plan to publish your package, you may want to make it a bit nicer for example by:

- giving your package a nice name
- fleshing out the `DESCRIPTION` file
- properly include your data as described [here](https://r-pkgs.org/data.html)
- add vignettes
- get your package to pass `devtools::check()`/"Check" under the build tab with no errors, warnings, or notes
