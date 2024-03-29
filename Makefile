#
# Make file to install/uninstall AsciiDoc
#

.NOTPARALLEL:

INSTALL = /usr/bin/install -c
INSTALL_PROG = ${INSTALL}
INSTALL_DATA = ${INSTALL} -m 644
PACKAGE_TARNAME = asciidoc
SED = /usr/bin/sed

prefix = /usr/local
exec_prefix = ${prefix}
bindir = ${exec_prefix}/bin
datadir = ${datarootdir}
docdir = ${datarootdir}/doc/${PACKAGE_TARNAME}
sysconfdir = ${prefix}/etc
datarootdir = ${prefix}/share
mandir=${datarootdir}/man
srcdir = .



ASCIIDOCCONF = $(sysconfdir)/asciidoc

prog = asciidoc.py a2x.py
progdir = $(bindir)

vimdir = ${prefix}/etc/vim

manp = $(patsubst %1.txt,%1,$(wildcard doc/*.1.txt))
manpdir = $(mandir)/man1

conf = $(wildcard *.conf)
confdir = $(ASCIIDOCCONF)

filtersdir = $(ASCIIDOCCONF)/filters

codefilter = filters/code/code-filter.py
codefilterdir = $(filtersdir)/code
codefilterconf = filters/code/code-filter.conf
codefilterconfdir = $(filtersdir)/code

graphvizfilter = filters/graphviz/graphviz2png.py
graphvizfilterdir = $(filtersdir)/graphviz
graphvizfilterconf = filters/graphviz/graphviz-filter.conf
graphvizfilterconfdir = $(filtersdir)/graphviz

musicfilter = filters/music/music2png.py
musicfilterdir = $(filtersdir)/music
musicfilterconf = filters/music/music-filter.conf
musicfilterconfdir = $(filtersdir)/music

sourcefilterconf = filters/source/source-highlight-filter.conf
sourcefilterconfdir = $(filtersdir)/source

latexfilter = filters/latex/latex2png.py
latexfilterdir = $(filtersdir)/latex
latexfilterconf = filters/latex/latex-filter.conf
latexfilterconfdir = $(filtersdir)/latex

themesdir = $(ASCIIDOCCONF)/themes

flasktheme = themes/flask/flask.css
flaskthemedir = $(themesdir)/flask

volnitskytheme = themes/volnitsky/volnitsky.css
volnitskythemedir = $(themesdir)/volnitsky

docbook = $(wildcard docbook-xsl/*.xsl)
docbookdir = $(ASCIIDOCCONF)/docbook-xsl

dblatex = $(wildcard dblatex/*.xsl) $(wildcard dblatex/*.sty)
dblatexdir = $(ASCIIDOCCONF)/dblatex

css = $(wildcard stylesheets/*.css)
cssdir = $(ASCIIDOCCONF)/stylesheets

js = $(wildcard javascripts/*.js)
jsdir = $(ASCIIDOCCONF)/javascripts

callouts = $(wildcard images/icons/callouts/*)
calloutsdir = $(ASCIIDOCCONF)/images/icons/callouts

icons = $(wildcard images/icons/*.png) images/icons/README
iconsdir = $(ASCIIDOCCONF)/images/icons

doc = $(wildcard README*) $(wildcard BUGS*) $(wildcard INSTALL*) $(wildcard CHANGELOG*)

DATATARGETS = manp conf docbook dblatex css js callouts icons codefilterconf musicfilterconf sourcefilterconf graphvizfilterconf latexfilterconf flasktheme volnitskytheme
PROGTARGETS = prog codefilter musicfilter graphvizfilter latexfilter
TARGETS = $(DATATARGETS) $(PROGTARGETS) doc

INSTDIRS = $(TARGETS:%=%dir)

.PHONY: $(TARGETS)

all: build

# create directories used during the install
$(INSTDIRS):
	$(INSTALL) -d $(DESTDIR)/$($@)

$(PROGTARGETS): % : %dir
	$(INSTALL_PROG) $($@) $(DESTDIR)/$($<)/

$(DATATARGETS): % : %dir
	$(INSTALL_DATA) $($@) $(DESTDIR)/$($<)/

$(manp): %.1 : %.1.txt
	python a2x.py -f manpage $<

docs:
	$(INSTALL) -d $(DESTDIR)/$(docdir)
	$(INSTALL_DATA) $(doc) $(DESTDIR)/$(docdir)
	$(INSTALL) -d $(DESTDIR)/$(docdir)/docbook-xsl
	$(INSTALL_DATA) docbook-xsl/asciidoc-docbook-xsl.txt $(DESTDIR)/$(docdir)/docbook-xsl
	$(INSTALL) -d $(DESTDIR)/$(docdir)/dblatex
	$(INSTALL_DATA) dblatex/dblatex-readme.txt $(DESTDIR)/$(docdir)/dblatex
	$(INSTALL) -d $(DESTDIR)/$(docdir)/stylesheets
	$(INSTALL_DATA) $(css) $(DESTDIR)/$(docdir)/stylesheets
	$(INSTALL) -d $(DESTDIR)/$(docdir)/javascripts
	$(INSTALL_DATA) $(js) $(DESTDIR)/$(docdir)/javascripts
	$(INSTALL) -d $(DESTDIR)/$(docdir)/images
	( cd images && \
		cp -R * $(DESTDIR)/$(docdir)/images )
	$(INSTALL) -d $(DESTDIR)/$(docdir)/doc
	( cd doc && \
		cp -R * $(DESTDIR)/$(docdir)/doc )
	$(INSTALL) -d $(DESTDIR)/$(docdir)/examples/website
	( cd examples/website && \
		cp -R * $(DESTDIR)/$(docdir)/examples/website )

progsymlink:
	(cd $(DESTDIR)/$(progdir); ln -sf asciidoc.py asciidoc)
	(cd $(DESTDIR)/$(progdir); ln -sf a2x.py a2x)

fixconfpath:
	@for f in $(prog); do \
		echo "Fixing CONF_DIR in $$f"; \
		$(SED) "s#^CONF_DIR = '.*'#CONF_DIR = '$(ASCIIDOCCONF)'#" $$f > $$f.out; \
		mv $$f.out $$f; \
		chmod +x $$f; \
	done

install-vim:
	@for d in $(DESTDIR)/$(vimdir) /etc/vim; do \
		if ! test -d $$d; then continue; fi ; \
		echo "installing Vim files in $$d" ; \
		$(INSTALL) -d $$d/syntax ; \
		$(INSTALL_DATA) vim/syntax/asciidoc.vim $$d/syntax ; \
		$(INSTALL) -d $$d/ftdetect ; \
		$(INSTALL_DATA) vim/ftdetect/asciidoc_filetype.vim $$d/ftdetect ; \
	done

uninstall-vim:
	@for d in $(DESTDIR)/$(vimdir) /etc/vim; do \
		if ! test -d $$d; then continue; fi ; \
		echo "uninstalling Vim files in $$d" ; \
		rm -f $$d/syntax/asciidoc.vim ; \
		rm -f $$d/ftdetect/asciidoc_filetype.vim ; \
	done


build: fixconfpath $(manp)


install: all $(PROGTARGETS) $(DATATARGETS) progsymlink install-vim

uninstall: uninstall-vim
	rm -f $(DESTDIR)/$(progdir)/asciidoc
	rm -f $(DESTDIR)/$(progdir)/asciidoc.py
	rm -f $(DESTDIR)/$(progdir)/a2x
	rm -f $(DESTDIR)/$(progdir)/a2x.py
	rm -f $(DESTDIR)/$(manpdir)/asciidoc.1
	rm -f $(DESTDIR)/$(manpdir)/a2x.1
	rm -rf $(DESTDIR)/$(confdir)
	rm -rf $(DESTDIR)/$(docdir)

clean:
	rm -f $(manp)

test:
	@echo "Nothing to see here...Move along."
