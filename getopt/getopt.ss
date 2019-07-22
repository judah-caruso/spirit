;; MIT License

;; Copyright (c) 2019 Judah Caruso Rodriguez

;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:

;; The above copyright notice and this permission notice shall be included in all
;; copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.


;; Package
;; ---------------------------------------------------------------------------

package: judah/spirit/getopt
namespace: judah/spirit/getopt

(import
  :judah/la
  :scheme/process-context
  (rename-in :judah/spirit (parse-command-line parse)))

(export
  parse-command-line
  parse-command-line-long)


;; Spirit/Getopt
;; ---------------------------------------------------------------------------

;; A redefinition of `parse-command-line`, using getopt instead.
(def* parse-command-line
    ((grammar)
      (parse getopt (cdr (command-line)) grammar))
        ((arguments grammar)
         (parse getopt arguments grammar)))


;; While getopt-long defines a matcher for double-dashed options
;; only, the `getopt-long-single` procedure exported by this library
;; implements the combined behavior of that and the standard
;; (single-dashed) `getopt` matcher.
(def getopt-long-single
  (let ((getopt-long getopt-long))
    (λ (arg grammar)
      (or (getopt-long arg grammar)
        (getopt arg grammar)))))


;; A staged parser that implicitly uses the `getopt-long-single` matcher.
(def* parse-command-line-long
    ((grammar)
      (parse getopt-long-single (cdr (command-line)) grammar))
    ((arguments grammar)
      (parse getopt-long-single arguments grammar)))


;; The standard `getopt` matcher.
(def (getopt arg grammar)
  (cond ((<= (string-length arg) 2) #f)
        ((not (char=? #\- (string-ref arg 0))) #f)
        ((assq (string->symbol (string-copy arg 0 2)) grammar) =>
         (λ (spec)
           (λ (args process)
             (process
              spec
              (cons (string-copy arg 0 2)
                    (if (null? (cdr spec))
                        (cons (let ((s (string-copy arg 2 (string-length arg))))
                                (if (char=? (string-ref s 0) #\-)
                                    s
                                    (string-append "-" s)))
                              (cdr args))
                        (cons (string-copy arg 2 (string-length arg))
                              (cdr args))))))))
        (else #f)))


(def getopt-long
  (let ((string-index
         (λ (s c)
           (let ((len (string-length s)))
             (let lp ((i 0))
               (cond ((= i len) #f)
                     ((char=? (string-ref s i) c) i)
                     (else (lp (+ i 1)))))))))
    (λ (arg grammar)
      (cond ((<= (string-length arg) 3) #f)
            ((not (string=? "--" (string-copy arg 0 2))) #f)
            ((string-index arg #\=) =>
             (λ (i)
               (cond ((assq (string->symbol (string-copy arg 0 i)) grammar) =>
                      (λ (spec)
                        (if (null? (cdr spec))
                            (error "Unexpected command line option value" arg)
                            (λ (args process)
                              (process
                               spec
                               (cons (string-copy arg 0 i)
                                     (cons (string-copy arg (+ i 1) (string-length arg))
                                           (cdr args))))))))
                     (else #f))))
            (else #f)))))
