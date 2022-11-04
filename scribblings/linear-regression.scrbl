#lang scribble/manual


@title{linear-regression}

@author[(author+email "Gabriel Haeck" "haeckgabriel@gmail.com")]

@defmodule[linear-regression]

This pakcage performs the basic tasks of Linear Regression in (base) Racket.
It supports univariate as well as multivariate covariates.
The code can be found @hyperlink["https://github.com/HaeckGabriel/RacketLinearRegression"]{here}.

@section{Installation}

To install this library, use:

@verbatim{raco pkg install linear-regression}

You can keep the package up to date by using

@verbatim{raco pkg update linear-regression}

@section{Using the Package}

The package gives public use to four functions:

@itemlist[@item{@tt{csv-transform}}
          @item{@tt{coeffs}}
          @item{@tt{predict}}
          @item{@tt{r2_adj}}]

@subsection{@tt{csv-transform}}

This function takes a @tt{csv} file as input.
More specifically, it is structured by @tt{rows}: The first row contains the observation data, and any subsequent row is a covariate.

It returns a list of two matrices: the first matrix is the observations, and the other matrix are your covariates (which may be multivariate).

@subsection{@tt{coeffs}}

This function takes the result from @tt{csv-transform} and calculates the regression coefficients, as a column matrix.


@subsection{@tt{predict}}

This function takes a matrix of coefficients (the result of @tt{coeffs}) and a @tt{vector} of new data, of the correct dimension.
It simply returns the predicted value given the coefficients.

@subsection{@tt{r2_adj}}

This function takes coefficients (result of @tt{coeffs}) and data set (result of @tt{csv-transform}) and calculates the @tt{adjusted} coefficient of correlation.
