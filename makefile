slides.pdf: slides.md style.tex screenshot.png
	pandoc --slide-level 2 -H style.tex -t beamer slides.md -o $@
