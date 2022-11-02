;;;; Linear Regression in (typed) Racket
;;;; as of now: given x data and y data, get betas.

#lang racket

(require math/matrix csv-reading)

(provide csv-transform coeffs predict r2_adj)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Linear Regression in Racket.
;; As of now, given a data set (covariates can be multivariate) we can obtain the coefficient estimate,
;; adjusted regression coefficient and perform predictions.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;; Reading csv file ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; custom reader for data.
(define data-csv-reader
  (make-csv-reader-maker
    '((seperator-chars #\,)
      (quote-char . #f))))

;; reads the csv file into a list per row. 
;; note: assumes that the csv file is on a 'per-row' basis, i.e.
;; the first row is your 'y' observations, the other rows are the covariates.
;; also assumes that there is no header.
(define (read-csv file)
  (csv->list (data-csv-reader (open-input-file file)))) ;; returns list

;; converts a list of strings to a list of numbers
;; e.g. (list "1" "2") becomes (list 1 2)
(define-syntax-rule (convert-list lst)
  (map (lambda (str)
         (string->number str))
       lst))

;; Take the list, take the first element and make it matrix of Y, and the rest matrix for X
;;!!! I don't like all the let* conditions... find a better way to do that.. break down into smaller funcs?
(define (transform-list lst)
  (let* ([y_list (car lst)]                                         ;; get the first row for y
         [y_list_numb (convert-list y_list)]                        ;; converts to list of numbers
         [x_list (list-tail lst 1)]                                 ;; rest for X mat
         [x_list_flat (flatten x_list)]                             ;; flatten to make X mat
         [x_list_flat_numb (convert-list x_list_flat)]              ;; list of strings to number
         [numb_row (length y_list_numb)]                            ;; number rows
         [numb_col (length x_list)]                                 ;; number cols
         [y_mat (list->matrix numb_row 1 y_list_numb)]              ;; builds y mat
         [x_mat (list->matrix numb_col numb_row x_list_flat_numb)]) ;; build x mat (builds by rows, so take transpose next line)
    (list y_mat (matrix-transpose x_mat))))                         ;; returns as list

;; Input a '.csv' file and return the tuple of y and x matrices.
(define (csv-transform csv_file)
  (transform-list (read-csv csv_file)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;; Obtain Coeffs and Predict ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; takes a matrix and pre-pends a column of ones.
;; keep as macro or change to function? not sure.. more performant? safer? idk..
(define-syntax-rule (make_x mat)
  (let* ([length_mat (matrix-num-rows mat)]      ;; number of rows to create mat of 1s
         [mat_one (make-matrix length_mat 1 1)]) ;; column matrix of ones
    (matrix-augment (list mat_one mat))))        ;; merge both matrices together

;; obtain $(X \cdot X^\transpose)^{-1} \cdot X^\transpose$,
;; GIVEN that $X$ has a pre-pended column of 1s
(define (x_op x_mat)
  (let* ([xt (matrix-transpose x_mat)]     ;; $X^\transpose$
         [x_xt (matrix* xt x_mat)]         ;; $X^\transpose \cdot X$
         [x_xt_inv (matrix-inverse x_xt)]) ;; $(X \cdot X^\transpose)^{-1}$
    (matrix* x_xt_inv xt)))                ;; $(X \cdot X^\transpose)^{-1} \cdot X^\transpose$

;; calculate the coefficients of the linear regression model:
;; $(X \cdot X^\transpose)^{-1} \cdot X^\transpose \cdot Y^\transpose$ ($Y^\transpose$ is a column matrix)
;; !!! In theory this function will accept a TUPPLE (x_mat, y_mat) and then do its thing..
(define (coeffs x_y_mat)      ;; x_y_mat is a list. 1st elem is Y, 2nd is X
  (let* ([y_mat (car x_y_mat)] 
         [x_mat (car (cdr x_y_mat))]
         [x_one (make_x x_mat)]
         [x_trans (x_op x_one)])
    (matrix* x_trans y_mat))) ;; now transform to vector? pretty-print? etc...

;; foldl version for vectors, used in predict() 
(define (vector-foldl f acc vec) ;; foldl for a vector
  (if (vector-empty? vec)
    acc
    (vector-foldl f
                  (f acc (vector-ref vec 0))
                  (vector-drop vec 1))))

;; given coefficients and data, get prediction. 
;; (make sure that coeffs vector and given data have the same size, see https://docs.racket-lang.org/reference/exns.html)
(define (predict coeffs x_vals)
  (let* ([coeffs_vec (matrix->vector coeffs)]
         [len_coeff (vector-length coeffs_vec)]
         [len_x (+ 1 (vector-length x_vals))]
         [x_vec (vector-append #(1) x_vals)]) ;; prepends 1 to vector of x values to perform mult.
    (if (not (= len_coeff len_x)) (error "Number of Coefficients and number of data points do not match.") 
      (let ([sum (vector-map * coeffs_vec x_vec)])
        (vector-foldl + 0 sum)))))          ;; element-wise multiplication of both vectors

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;; Correlation Coefficient ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; ok so start by gettin SSE and SSTO.
(define (sse beta x_mat y_mat) ;; all in matrix from. X (n x p), Y (n x 1) and beta (p x 1)
  (let ([one (matrix* (matrix-transpose y_mat) y_mat)]                          ;; $Y^\transpose \cdot Y$
        [two (matrix* (matrix-transpose beta) (matrix-transpose x_mat) y_mat)]) ;; $b^\transpose \cdot X^\transpose \cdot Y$
    (matrix-ref (matrix- one two) 0 0)))                                        ;; from 1x1 matrix to numeric

;; Get SSTO: $Y^\transpose \cdot Y - \frac{1}{n} \cdot Y^\transpose \cdot J \cdot Y$, $J$ a matrix with entries 1
(define (ssto y_mat)
  (let* ([size_y (matrix-num-rows y_mat)]                               ;; number of observations
         [j_mat (make-matrix size_y size_y 1)]                          ;; create matrix of ones
         [yt_y (matrix* (matrix-transpose y_mat) y_mat)]                ;; $Y^\transpose \cdot Y$
         [yt_j_y (matrix* (matrix-transpose y_mat) j_mat y_mat)]        ;; $Y^\transpose \cdot J \cdot Y$
         [yt_j_y_scaled (matrix-map (lambda (x) (/ x size_y)) yt_j_y)]) ;; above matrix times $\frac{1}{n}$ for each entry
    (matrix-ref (matrix- yt_y yt_j_y_scaled) 0 0)))                     ;; from 1x1 matrix to numeric

;; Get $R^2_{\text{a}}$ (adjusted R^2 coefficient), given by
;; $R^2_{\text{a}} = 1 - \frac{\frac{\text{SSE}}{n - p}}{\frac{\text{SSTO}}{n-1}} 
;; = 1 - \left( \frac{n-1}{n-p} \right) \cdot \frac{ \text{SSE} }{ \text{SSTO} }$,
;; where $p$ is the number of regressors and $n$ the number of observations.
(define (r2_adj beta x_y_mat)
  (let* ([y_mat (car x_y_mat)]
         [x_mat (car (cdr x_y_mat))]
         [numb_obs (matrix-num-rows y_mat)]                ;; number of obs, i.e. $n$
         [numb_reg (matrix-num-cols x_mat)]                ;; number of preds i.e. $p$
         [sse_val (sse beta (make_x x_mat) y_mat)]         ;; calculate $\text{SSE}$ ($X$ with col of ones pre-pended)
         [ssto_val (ssto y_mat)]                           ;; get $\text{SSTO}$
         [factor (/ (- numb_obs 1) (- numb_obs numb_reg))] ;; factor $ \frac{n-1}{n-p}$
         [sse_ssto (/ sse_val ssto_val)]                   ;; $ \frac{ \text{SSE} }{ \text{SSTO} }$
         [mult_vals (* factor sse_ssto)])                  ;; $\left( \frac{n-1}{n-p} \right) \cdot \frac{ \text{SSE} }{ \text{SSTO} }$
    (- 1 mult_vals)))                

;; do ANOVA? Need F-dist in Racket..

;; Confidence Intervals? Need t-dist in Racket..
