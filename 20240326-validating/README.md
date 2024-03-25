# Agenda

Last week, everyone wanted to use R so this week I only made the material in R. If there is demand to translate to python, I'm happy to do so and run a follow up workshop.

-   Getting started
    -   Clone repo
    -   Install testthat
    -   Set your working directory to `20240326-validating`
-   Using Tests to Validate Code
    -   Demo: test better_shapes.R::parse_shape_definition_line
        -   Test existing functionality
        -   Prepare for triangle with params: a, b, c
        -   [Results](https://github.com/livingingroups/eas-coding-workshops/blob/validating-after-bettershapes-demo/20240326-validating/tests/test_better_shapes.R)
    -   Exercise: test better_shapes.R::calculate_shape_area
        -   Testing existing functionality with a larger variety of inputs
            -   Try to find the bug. If you see it, demonstrate it with a test.
        -   Later: you can try adding the triangle functionality as practice.
-   Applying Testing to Data Processing
    -   Show and tell: full data processing script
    -   Demo: Applying validation to a data processing script
    -   Exercise: Applying Validation to data processing script
-   Final Notes
    -   [Running testthat is easier with packaging](https://github.com/r-lib/testthat/issues/659#issuecomment-478559396)
    -   Mocks (whiteboard explanation)
        -   Helps when you
            -   are calling a function that takes a really long time even with a little data. (e.g. a model)
            -   want to code surrounding a function call without assuming that function you're calling is working properly. (e.g. testing the `process` function in better_shapes without implicitly testing the other functions.)
            -   
        -   Trickyness in R
            -   it's easier to put your code into package format (put your code in `R` folder and add a DESCRIPTION file) than it is to try using mocks without doing so.
            -   
    -   Isn't a lot of work? [Yes](https://github.com/pminasandra/bout-duration-distributions/tree/master/tests), but
        -   as an author, you have to check if your code is working anyway. This is a way to save the tests you're already doing. Also, you can speed up i iterations, because you're running it on tiny bits of data to test it.   
        -   as a code reviewer, you can get [coauthorship](https://www.biorxiv.org/content/10.1101/2024.01.20.576411v3)
        -   you do actually find [bugs](https://github.com/pminasandra/bout-duration-distributions/blob/c09931fe68bdcaeb27b349c68c97d441b9943322/simulations/simulator.py#L70-L104) that would otherwise go unnoticed. [fix here](https://github.com/pminasandra/bout-duration-distributions/commit/c535ed4ceb05e3215823c17c655fd0d3c22c09cc)

# ToDo

-   create mocks example
-   run through examples for time and to create key
