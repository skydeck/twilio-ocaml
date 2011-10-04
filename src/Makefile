NAME = twilio
ATDS := $(wildcard *.atd)
ATDT := $(ATDS:.atd=_t.ml)
ATDJ := $(ATDS:.atd=_j.ml)
SRCS := $(NAME)_types.ml $(NAME)_util.ml $(NAME)_rest.ml $(NAME)_rest_request.ml $(NAME)_rest_convenience.ml $(NAME)_rest_printer.ml $(ATDT) $(ATDJ)
CMAS := $(NAME).cma
CMXAS := $(NAME).cmxa
CMIS := $(SRCS:.ml=.cmi)
LIBS = $(CMAS) $(CMXAS)
BUILD = $(addprefix _build/,$(LIBS)) $(addprefix _build/,$(CMIS)) _build/$(NAME).a

.PHONY: all atd install uninstall clean

all: atd $(NAME).mllib
	ocamlbuild -tag debug $(LIBS)

atd: $(ATDT) $(ATDJ)

install:
	ocamlfind install $(NAME) $(BUILD) META

uninstall:
	ocamlfind remove $(NAME)

clean:
	rm -f $(NAME).mllib
	rm -f $(ATDT) $(ATDJ) $(ATDT:.ml=.mli) $(ATDJ:.ml=.mli)
	ocamlbuild -clean

$(NAME).mllib:
	echo $(SRCS) | perl -pe 's/ /\n/g'  | perl -pe 's/^./\U$$&/g' | sed -e "s/\.ml//g" > $@

%_t.ml: %.atd
	atdgen -t $<

%_j.ml: %.atd
	atdgen -j $<
