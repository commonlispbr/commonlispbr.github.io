EMACS_INIT  := /root/.emacs.d/init.el
EMACS_LOAD  := -l $(EMACS_INIT)
EMACS_FLAGS := --batch --kill $(EMACS_LOAD)
ORG_FILES   := $(wildcard *.org)
HTML_FILES  := $(patsubst %.org, %.html, $(ORG_FILES))
DOCKER_IMG  := commonlispbr/emacs
USER        := $(shell id -u):$(shell id -g)
DOCKER_RUN  := docker run  -w /tmp \
	                       -v $(shell pwd):/tmp \
                           --rm \
                           -t
STATUS_PREFIX    := "\033[1;32m[+]\033[0m "
ATTENTION_PREFIX := "\033[1;36m[!]\033[0m "

.PHONY: clean shell

all: $(HTML_FILES)

shell:
	$(DOCKER_RUN) -i --entrypoint=/bin/zsh $(DOCKER_IMG)

%.html: %.org
	@printf $(STATUS_PREFIX); echo "COMPILING: $< -> $*.html"
	@$(DOCKER_RUN) $(DOCKER_IMG) $< $(EMACS_FLAGS) -f org-html-export-to-html
	@$(DOCKER_RUN) --entrypoint=/bin/chown $(DOCKER_IMG) $(USER) "$*.html"

server:
	python3 -m http.server 8000

clean:
	rm -rf *.html
