

all:
	ocamlbuild -r -use-ocamlfind -pkgs yojson,lwt,ocsigenserver -tags thread,annot,safe_string flickground.native


clean:
	ocamlbuild -clean
