# Setup

- Clone repo or pull latest changes
- install requirements
'''
install.packages()
TODO - add rethinking github link
'''


# Intro

A lot of this is my own workflow/opinion, with some general principles mixed in. Please take what works for you and leave what doesn't behind.

# Stages

## Simple Script

### Recommendations
- Keep data and code in separate folders
- Outputs directory
- Define each relevant folder (in this case, maybe just code and data folders) at the beginning of the script. 

### Tool: validate package

## Script with functions

### Problems it solves

I keep copying and pasting the same code in multiple places in my script. Then if I want to modify it, I have to do find and replace which doesn't always work.

My script is getting long enough that I have lots and lots of objects in my workspace and it's hard to remember what everything is. It's also hard to figure out what does or doesn't ened to get re-run.

### How it looks

Everything is still in one script, but the script as two parts. At the top, you define all the functions you use (some might call each other). At the bottom, the "runner" section of the script calls a few of these functions to kick off the process.


### :tools: Targets
 
 TODO

### :tools: Browser

TODO

## Three File Workflow

### Problems it solves

When I'm writing my code, I do a lot of running and rerunning with a small part. It's hard to keep track of which code is left over from this process and which is part of my "real" script. 

### :tools: Rmd

## Package

### Problems it solves

My file with functions is getting really long. I want to break it into separate scripts, but then, I'd have to add "source()" everywhere.

### How it 



