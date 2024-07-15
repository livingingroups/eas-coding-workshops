# Overall script purpose
  For each encounter
  - did they move together?
  - did they sleep together the night before or night after
  
  
  Move together 
  - have to be within 80th quantile of intragroup distance
  - move 100 meters together


# Readability

## What makes the code easier or hard to understand

Easy
- broken up into sections
- enough space between different parts of the code, but made it a little hard to identify what loops we're in
- Design of different DFs for different granularity seems nice - would be even nicer to explicitly document this design
- Micro comments helpful


Hard
- annotation was variable: loops were clear, unclear what the plots were plotting

## How could this code be more readable?

- Subsections
- Macro structure apparent at the beginning
- Description of expected output







# Brock Comments Readability
## pros

In the micro clear line by line what you're doing


## ways to improve
- More clear large section heading.
- Maybe even separate into separate scripts
  - functions to check sleeptogetherness
  - functions to check movetogetherness
  - function to put sleeptogetherness, movetogetherness, encounters
  - plotting and data display functions
  - script to put it all together.
- Especially in "Move together" section, there are peices  that can be pulled out.
- where you have print statements, would be good to print a label. likewise when you're checking summary statistics, would be good to mark what you're looking for in those statistics
- Unclear exactly what a row in  "comove" df represents


# Brock Comments on effectiveness

- You are calculating "did they sleep together on night X" twice
