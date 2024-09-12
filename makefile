slides.pdf: slides.md style.tex screenshot.png makefile
	pandoc --slide-level 2 -H style.tex -t beamer slides.md -o $@

images: slides.pdf
	mkdir -p images
	mutool convert -o images/slides%02d.png -O width=1440 slides.pdf
