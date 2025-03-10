EMACS_INIT          := /root/.emacs.d/init.el
EMACS_LOAD          := -l $(EMACS_INIT)
EMACS_FLAGS         := --batch --kill $(EMACS_LOAD)
ORG_FILES           := $(wildcard *.org)
HTML_FILES          := $(patsubst %.org, %.html, $(ORG_FILES))
STATIC_FILES_FOLDER := static/
DOCKER_IMG          := commonlispbr/emacs
MINIFY_IMG          := tdewolff/minify
USER                := $(shell id -u):$(shell id -g)
DOCKER_RUN          := docker run  -w /tmp \
	                               -v $(shell pwd):/tmp \
                                   --rm \
                                   -t
MINIFY              := $(DOCKER_RUN) --entrypoint="/usr/bin/minify" $(MINIFY_IMG)

STATUS_PREFIX       := "\033[1;32m[+]\033[0m "

.PHONY: clean shell

all: setup $(HTML_FILES) minify copy

shell:
	$(DOCKER_RUN) -i --entrypoint=/bin/zsh $(DOCKER_IMG)

setup:
	@printf $(STATUS_PREFIX); echo "CREATING STATIC FOLDER: $(STATIC_FILES_FOLDER)"
	@mkdir -p static

%.html: %.org
	@printf $(STATUS_PREFIX); echo "COMPILING: $< -> $*.html"
	@$(DOCKER_RUN) $(DOCKER_IMG) $< $(EMACS_FLAGS) -f org-html-export-to-html
	@mv $*.html $(STATIC_FILES_FOLDER)/$*.html
	@printf $(STATUS_PREFIX); echo "MINIFYING: $*.html"
	@$(MINIFY) $(STATIC_FILES_FOLDER)/$*.html -o $(STATIC_FILES_FOLDER)/$*.html

minify:
	@printf $(STATUS_PREFIX); echo "MINIFYING AND BUNDLING CSS FILES"
	@$(MINIFY) --bundle org-theme/dist/long/bundle.css css/syntax.css -o $(STATIC_FILES_FOLDER)/long.css
	@$(MINIFY) --bundle org-theme/dist/short/bundle.css css/syntax.css -o $(STATIC_FILES_FOLDER)/short.css
	@printf $(STATUS_PREFIX); echo "MINIFYING JS FILES"
	@$(MINIFY) --bundle org-theme/dist/long/bundle.js -o $(STATIC_FILES_FOLDER)/long.js
	@$(MINIFY) --bundle org-theme/dist/long/bundle.js -o $(STATIC_FILES_FOLDER)/short.js

copy:
	@printf $(STATUS_PREFIX); echo "COPYING IMAGE FILES"
	@cp images/logo.png $(STATIC_FILES_FOLDER)/logo.png

server:
	python3 -m http.server 8000 --directory $(STATIC_FILES_FOLDER)

clean:
	rm -rf $(STATIC_FILES_FOLDER)
