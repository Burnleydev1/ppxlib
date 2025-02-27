(lang dune 2.7)
(name ppxlib)
(using cinaps 1.0)
(allow_approximate_merlin)
(implicit_transitive_deps false)
(cram enable)
(generate_opam_files true)

(source (github ocaml-ppx/ppxlib))
(license MIT)
(authors "Jane Street Group, LLC <opensource@janestreet.com>")
(maintainers "opensource@janestreet.com")
(documentation "https://ocaml-ppx.github.io/ppxlib/")

(package
 (name ppxlib)
 (depends
  (ocaml (and (and (>= 4.04.1) (< 5.2.0)) (<> 5.1.0~alpha1)))
  (ocaml-compiler-libs (>= v0.11.0))
  (ppx_derivers (>= 1.0))
  (sexplib0 (>= v0.12))
  (sexplib0 (and :with-test (>= "v0.15"))) ; Printexc.register_printer in sexplib0 changed
  stdlib-shims
  (ocamlfind :with-test)
  (re (and :with-test (>= 1.9.0)))
  (cinaps (and :with-test (>= v0.12.1))))
 (conflicts
  (ocaml-migrate-parsetree (< 2.0.0))
  base-effects)
 (synopsis "Standard infrastructure for ppx rewriters")
 (description "Ppxlib is the standard infrastructure for ppx rewriters
and other programs that manipulate the in-memory representation of
OCaml programs, a.k.a the \"Parsetree\".

It also comes bundled with two ppx rewriters that are commonly used to
write tools that manipulate and/or generate Parsetree values;
`ppxlib.metaquot` which allows to construct Parsetree values using the
OCaml syntax directly and `ppxlib.traverse` which provides various
ways of automatically traversing values of a given type, in particular
allowing to inject a complex structured value into generated code.
"))

(package
 (name ppxlib-bench)
 (synopsis "Run ppxlib benchmarks")
 (description "Third-party code in benchmarks depends on later versions of the ocaml
than ppxlib itself. Also the benchmark runner has dependencies that ppxlib doesn't
have.")
 (depends
  (ocaml (>= 4.04.1))
  (ppxlib (= :version))
  base
  yojson))
