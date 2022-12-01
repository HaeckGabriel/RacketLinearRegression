<h1 align="center"> Linear Regression in Racket </h1>

<h4 align="center"> The Linear Regression methodology in Racket. </h4>

<p align="center">
    <a href="https://github.com/HaeckGabriel/gev-distribution/releases/tag/gev-distribution">
    <img src="https://img.shields.io/badge/Version-1.0.0-blueviolet?style=for-the-badge&logo=Racket">
  </a>
</p>

<p align="center">
  <a href="#Reading a csv file">Reading a csv file</a> •
  <a href="#Basics">Basics</a>
</p>

This library performs linear regression in base Racket.
More precisely, it obtains the coefficients of regression, calculates the adjusted coefficient of correlation and lets users predict an outcome given an observation and coefficients.
This package works for multivariate covariates.

The Racket package can also be viewed [here](https://pkgd.racket-lang.org/pkgn/package/linear-regression).

An example is provided in the `example` folder.

### Reading a csv file
The `csv-transform` function reads a csv file as input and returns a list with the first element being the observation values ( $Y$ ) and the second element being the covariates ( $X$ ).
**Note**: The data is entered by *rows* and not columns. That is, the first row of the csv file are your observation data, and each subsequent row is a covariate.

## Basics

### Obtaining the Coefficients
The coefficients $\hat{\beta}$ are obtained as follows:

$$ \hat{\beta} = (X \cdot X^\top)^{-1} \cdot X^\top \cdot Y^\top $$

### Adjusted Coefficient of Regression
The adjusted Coefficient of Regression, denoted $R^2_\text{a}$, is defined as

$$ R^2_\text{a} =  1 - \left( \frac{n-1}{n-p} \right) \cdot \frac{ \text{SSE} }{ \text{SSTO} }. $$

Note that if we consider the univariate case, that is $p = 1$, we recuperate the well-known $R^2$ formula.


## Features
What this package accomplishes/wants to accomplish in the future
- [x] Read user input for csv file
- [x] Obtain Coefficients
- [x] Perform Predictions given Coefficients and new data
- [x] Calcualte $R^2_{\text{a}}$
- [ ] Get Confidence Intervals for each coefficient
- [ ] Perform ANOVA
