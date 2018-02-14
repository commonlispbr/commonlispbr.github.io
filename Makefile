EMACS_INIT  := ~/.emacs.d/init.el
EMACS_LOAD  := -l $(EMACS_INIT)
EMACS_FLAGS := --batch --kill $(EMACS_LOAD)
ORG_FILES   := $(wildcard *.org)
HTML_FILES  := $(patsubst %.org, %.html, $(ORG_FILES))

.PHONY: clean

all: $(HTML_FILES)

%.html: %.org
	emacs $< $(EMACS_FLAGS) -f org-html-export-to-html

clean:
	rm -rf *.html
