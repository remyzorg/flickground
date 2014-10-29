

all:
	ocamlbuild -r -use-ocamlfind flickground.native


clean:
	ocamlbuild -clean
