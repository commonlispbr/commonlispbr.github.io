ORG_FILES  := $(wildcard *.org)
HTML_FILES := $(patsubst %.org, %.html, $(ORG_FILES))

.PHONY: clean

all: $(HTML_FILES)

%.html: %.org
	emacs $< --batch -f org-html-export-to-html --kill

clean:
	rm -rf *.html
