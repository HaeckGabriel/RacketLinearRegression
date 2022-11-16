#lang racket

(require linear-regression)

(define x_y_mat (csv-transform "data.csv")) ;; create the x and y matrices

(coeffs x_y_mat) ;; calculate the coefficients

(r2_adj (coeffs x_y_mat) x_y_mat) ;; calculate adjusted R^2
