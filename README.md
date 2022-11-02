# RacketLinearRegression
This library performs linear regression in base Racket.
More precisely, it obtains the coefficients of regression, calculates the adjusted coefficient of correlation and lets users predict an outcome given an observation and coefficients.
This package works for multivariate covariates.

This sentence uses `$` delimiters to show math inline:  $Y$

### Reading a csv file
The `csv-transform` function reads a csv file as input and returns a list with the first element being the observation values ($Y$) and the second element being the covariates ($X$).
**Note**: The data is entered by *rows* and not columns. That is, the first row of the csv file are your observation data, and each subsequent row is a covariate.

## Stuff to describe more
- [ ] Must input one csv file (BY ROW, not cols) 

## Features
List of specific things to accomplish:
- [x] Read user input for csv file
- [x] Get coefficients
- [x] Perform Predictions given Coefficients and new data
- [ ] Confidence Intervals for each coefficient
- [ ] (?) ANOVA

## To Do
- [ ] Add scribble file.
