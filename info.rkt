#lang info

(define name "Regression")

;; version
(define version "1.0")

;; dependencies
(define deps '("base"
               "math-lib"
               "csv-reading"))
 
 ;; build-dependencies
(define build-deps '("scribble-lib"
                     "racket-doc"))
               
;; Documentation               
(define scribblings
  '(("scribblings/linear-regression.scrbl" ())))
