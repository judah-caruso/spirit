(import
  :std/test
  :judah/spirit/getopt)


;; Utilities
;; ---------------------------------------------------------------------------

(def (test-parse parser line grammar expected)
  (displayln "Test variables:")
  (displayln "\t   input: " line)
  (displayln "\t grammar: " grammar)
  (displayln "\t  output: " (parser line grammar))
  (displayln "\texpected: " expected)
  (check-equal? (parser line grammar) expected))


;; Tests
;; ---------------------------------------------------------------------------

(def getopt-test
  (test-suite "Spirit 'getopt' test suite"
    (test-case "Single flag command parsing"
      (test-parse parse-command-line
        '("-abcone" "-d" "two")
        '((-a) (-b) (-c . foo) (-d . bar))
        '((-a) (-b) (-c . "one") (-d . "two") (--))))

    (test-case "Flag folding"
      (test-parse parse-command-line
        '("-aone" "bar" "--foo")
        '((-a b) (--foo) (bar . baz))
        '((-a "one") (bar . "--foo") (--))))

    (test-case "Ignoring invalid flags"
      (test-parse parse-command-line
        '("-abfoo" "-cfoo" "--" "-d")
        '((-a foo) (-b) (-c) (-d))
        '((-a "bfoo") (-c) (-- "-foo" "-d"))))

    (test-case "Converting values via grammar"
      (test-parse parse-command-line
        '("foo" "bar" "42" "qux")
        `((foo ,list ,string->number ,string->symbol))
        '((foo ("bar") 42 qux) (--))))))


(def getopt-long-test
  (test-suite "Spirit 'getopt-long' test suite"
    (test-case "Assigned flags"
      (test-parse parse-command-line-long
        '("--foo" "--bar=one" "--baz" "two")
        '((--foo) (--bar . h) (--baz . k))
        '((--foo) (--bar . "one") (--baz . "two") (--))))

    (test-case "Invalid assignment"
      (test-parse parse-command-line-long
        '("--foo" "--bar=" "--" "--baz")
        '((--foo) (--bar x) (--baz))
        '((--foo) (--bar "") (-- "--baz"))))

    (test-case "Converting long values via grammar"
      (test-parse parse-command-line-long
        '("--foo" "string-val" "0")
        `((--foo ,string->symbol ,string->number))
        '((--foo string-val 0) (--))))))


;; Test Execution
;; ---------------------------------------------------------------------------

(apply run-tests! [getopt-test getopt-long-test])
(test-report-summary!)

(case (test-result)
  ((OK) (exit 0))
  (else (exit 1)))
