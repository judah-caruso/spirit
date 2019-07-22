(import
  :std/test
  :judah/spirit)


;; Utilities
;; ---------------------------------------------------------------------------

(def (test-parse line grammar expected)
  (displayln "Test variables:")
  (displayln "\t   input: " line)
  (displayln "\t grammar: " grammar)
  (displayln "\t  output: " (parse-command-line line grammar))
  (displayln "\texpected: " expected)
  (check-equal? (parse-command-line line grammar) expected))


;; Tests
;; ---------------------------------------------------------------------------

(def command-line-test
  (test-suite "Spirit standard parse-command-line test suite"
    (test-case "Single command parsing"
      (test-parse
        '("foo" "bar")
        '((foo . bar))
        '((foo . "bar") (--))))

    (test-case "Multiple command parsing"
      (test-parse
        '("foo" "bar" "baz" "qux")
        '((foo) (bar baz qux))
        '((foo) (bar "baz" "qux") (--))))

    (test-case "Extra/excess command parsing"
      (test-parse
        '("foo" "bar" "baz")
        '((foo . bar))
        '((foo . "bar") (-- "baz"))))

    (test-case "Extra/excess command parsing"
      (test-parse
        '("foo" "bar" "--" "baz" "qux")
        '((foo . bar) (baz . qux))
        '((foo . "bar") (-- "baz" "qux"))))

    (test-case "Grouped command parsing"
      (test-parse
        '("foo" "bar" "baz" "qux")
        '(((foo bar baz) . qux))
        '((foo . "bar") (baz . "qux") (--))))))


;; Test Execution
;; ---------------------------------------------------------------------------

(apply run-tests! [command-line-test])
(test-report-summary!)

(case (test-result)
  ((OK) (exit 0))
  (else (exit 1)))
