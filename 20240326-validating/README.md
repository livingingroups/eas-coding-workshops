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
    -   Demo: Applying validation to a data processing script (add deployment id)
        -   [Results](https://github.com/livingingroups/eas-coding-workshops/blob/validating-after-deploymentid-demo/20240326-validating/tests/test_add_deployment_id.R)
    -   Exercise: Applying validation to data processing script (add time lag)
-   Final Notes
    -   [Running testthat is easier with packaging](https://github.com/r-lib/testthat/issues/659#issuecomment-478559396)
    -   Mocks (whiteboard explanation)
        -   Helps when you
            -   are calling a function that takes a really long time even with a little data. (e.g. a model)
            -   want to code surrounding a function call without assuming that function you're calling is working properly. (e.g. testing the `process` function in better_shapes without implicitly testing the other functions.)
            -   want to test code that has some randomness, but you want your tests to be deterministic
        -   Trickyness in R
            -   it's easier to put your code into package format (put your code in `R` folder and add a DESCRIPTION file) than it is to try using mocks without doing so.
            -   because the latest and greatest mocking functions just came out recently, there aren't great examples for how to use them. (I'm happy to create some once folks get to this point.)
    -   Isn't a lot of work? [Yes](https://github.com/pminasandra/bout-duration-distributions/tree/master/tests), but
        -   as an author, you have to check if your code is working anyway. This is a way to save the tests you're already doing. Also, you can speed up i iterations, because you're running it on tiny bits of data to test it.   
        -   as a code reviewer, you can get [coauthorship](https://www.biorxiv.org/content/10.1101/2024.01.20.576411v3)
        -   you do actually find [bugs](https://github.com/pminasandra/bout-duration-distributions/blob/c09931fe68bdcaeb27b349c68c97d441b9943322/simulations/simulator.py#L70-L104) that would otherwise go unnoticed. [fix here](https://github.com/pminasandra/bout-duration-distributions/commit/c535ed4ceb05e3215823c17c655fd0d3c22c09cc)
        -   it's a lifesaver when improving working code. (e.g. making it run faster or adding functionality)
