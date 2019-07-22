# Spirit

An *in spirit* port to [Gerbil Scheme](https://cons.io/) of [Evan Hanson's](www.foldling.org) R7RS command line parsing library, [Optimism](http://wiki.call-cc.org/eggref/5/optimism).

### Description

Spirit is a minimal library, allowing you to easily parse various types of command line arguments. It also uses some of Gerbil Scheme's features, and will use more in the future.

### Installation
To install Spirit, you can use Gerbil Scheme's package manager `gxpkg`:
`gxpkg install github.com/kyoto-shift/spirit`

You can also install it manually (recommended):  

```shell
$ git clone https://github.com/kyoto-shift/spirit.git
$ cd spirit
$ chmod +x ./build.ss
$ ./build.ss
```

Doing either will install two packages:  

* `:judah/spirit`
* `:judah/spirit/getopt` (A getopt-styled parser)

### Usage

Two procedures are provided:  

* `parse-command-line`
* `parse-command-line-long` (only in `:judah/spirit/getopt`)

Both procedures take an optional list of command line arguments and a grammar *(association list of symbols)*. If no list of command line arguments is given, Spirit will use the `(command-line)` procedure provided by `:scheme/process-context`.

#### Examples:

This is a very simple example where we provide arguments and a basic grammar using the default parser. Notice the `(--)` at the end of the output. Spirit automatically catches any unhandled arguments and places them in the `--` list.

```scheme
(import :judah/spirit) ;; for the default parser

(parse-command-line
  '("-a" "1" "-b" "2") ;; optional
  '((-a . a-val) (-b . b-val)))

;; => ((-a "1") (-b "2") (--))
```


Another way we can process arguments is by adding procedures to our grammar. Procedure arguments are replaced by the value they return when called on the corresponding item. Notice that we're using a back-tick ``` ` ``` in front of our grammar rather than an apostrophe `'`.  

```scheme
(import :judah/spirit)

(parse-command-line
  '("-f" "val" "-a" "1" "2") ;; optional
  `((-f ,string->symbol) (-a ,string->number ,string->number))

;; => ((-f val) (-a 1 2))
```

We can also use a special case in our grammar. If the first element of a grammar entry is a list, the elements of that list will be split into separate entries, keeping their assigned value. This allows you to specify multiple grammar entries of the same form.  

```scheme
(import :judah/spirit)

(parse-command-line
  '("-a" "1" "-b" "2" "-c" "3")
  `(((-a -b -c) ,string->number)))

;; => '((-a 1) (-b . 2) (-c . 3))
```

If we'd like to use `getopt` and `getopt_long`-styled commands, we can import `:judah/spirit/getopt`. Note, importing this after Spirit will redefine `parse-command-line` to use the `getopt` parser instead of the default one. However, you can also rename either procedure if you'd like to access both at the same time:  

```scheme
(import
  :judah/spirit           ;; import the default package
  (rename-in :judah/spirit/getopt ;; import 'getopt' and use 'rename-in' so we keep both
    (parse-command-line parse-getopt)
    (parse-command-line-long parse-getopt-long))) ;; optional
 ```

`:judah/spirit/getopt` has two variations of the `parse-command-line` procedure:
* `parse-command-line` uses the default `getopt`-styled parser.
* `parse-command-line-long` uses the `getopt-long`-styled parser.

We can use the `getopt`-styled parsers like so:
```scheme
(import :judah/spirit/getopt)

(parse-command-line
  '("-aone" "-btwo")
  '((-a . val) (-b . val)))

;; => ((-a . "one") (-b . "two") (--))

;; If we'd like to use longer flags like '--help' or '--version',
;; we can instead use 'parse-command-line-long'.

(parse-command-line-long
  '("--help")
  '((--help) (--version) (-t))

;; => ((--help) (--))
```

Here's a small, but more realistic example of how we could use Spirit:  

```scheme
(import
  (rename-in (only-in :judah/spirit/getopt parse-command-line-long)
    (parse-command-line-long getopt-long)))

;; [NAME, AGE, usage!, contains?, age->birthyear, etc.]

(def (process-args)
  (if (<= (length (command-line)) 0)
    (usage! 0)
    (begin
      (def args (getopt-long
        `((-n ,string->symbol) (-a ,age->birthyear))))
      (cond
        ((contains? '-n args) (set! NAME (assocval (assoc '-n args))))
        ((contains? '-a args) (set! AGE (assocval (assoc '-a args))))))))

;; [...]
```


#### Tests

Tests can be run like so: `gxi tests/name-of-test.ss`

### License

[MIT License](LICENSE)
