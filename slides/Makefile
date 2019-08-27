# Agda 2.5.4.2 misses the html-highlight option
# agda=agda-2.5.4.2

agda=agda --html-highlight=auto

patchTheme=patchTheme.css

default: slides1.html slides2.html slides3.html slides4.html

REVEALJS_URL=https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.7.0/

vpath reveal.js $(HOME) .

%.html: _build/%.md reveal.js white.css $(patchTheme) Agda.css Makefile $(patchTheme)
	pandoc -t revealjs -V revealjs-url=$(REVEALJS_URL) --css=white.css --css=Agda.css --css=$(patchTheme) --mathjax -s $< -o $@

_build/%.md: %.lagda.md
	$(agda) --html --html-dir=_build --html-highlight=auto $<

./reveal.js:
	git clone https://github.com/hakimel/reveal.js

# EOF
