.PHONY: serve
serve:
	jekyll serve -D -P 8000


.PHONY: build
build:
	jekyll build


.PHONY: deploy
deploy:
	jekyll build
	git add -A
	git commit
