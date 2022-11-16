#lang racket

(require linear-regression)

(define x_y_mat (csv-transform "data.csv"))

(coeffs x_y_mat)

(r2_adj (coeffs x_y_mat) x_y_mat)
