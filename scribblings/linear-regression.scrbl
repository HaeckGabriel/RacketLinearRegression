#lang scribble/manual

@title{linear-regression}

@author[(author+email "Gabriel Haeck" "haeckgabriel@gmail.com")]

@defmodule[linear-regression/main.rkt]

This pakcage performs the basic tasks of Linear Regression in (base) Racket.
It supports univariate as well as multivariate covariates.
The code can be found @hyperlink["https://github.com/HaeckGabriel/RacketLinearRegression"]{here}

@section{Installation}

To install this library, use:

@verbatim{raco pkg install linear-regression}

You can keep the package up to date by using

@verbatim{raco pkg update linear-regression}

@section{Using the Package}

The package gives public use to four functions:

@itemlist[@item{@csv-transform}
          @item{@coeffs}
          @item{@predict}
          @item{@r2_adj}]
