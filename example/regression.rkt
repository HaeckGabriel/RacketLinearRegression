#lang racket

(require linear-regression)

(define x_y_mat (csv-transform "data.csv")) ;; create the x and y matrices

(coeffs x_y_mat) ;; calculate the coefficients

(r2_adj (coeffs x_y_mat) x_y_mat) ;; calculate adjusted R^2

(predict (coeffs x_y_mat) (vector 1 2)) ;; calculate a prediction. New x values must be a vector.
