# ..example
# 	dev-serve

.PHONY: dev-serve
dev-serve:
	jekyll serve -D -P 8000

# ..example
# 	prod-serve

.PHONY: prod-serve
prod-serve:
	jekyll serve -P 8000

# ..example
# 	build

.PHONY: build
build:
	jekyll build

# params:
# 	- tag: the tag associated with this release
#
# ..example:
# 	 make release tag=v0.0.1-rc

.PHONY: release
release:
ifndef tag
	$(error tag is not set, see Makefile comments)
endif

	@echo Creating build for $(tag)...

	rm -rf ~/jekyll/build
	mkdir -p ~/jekyll/build
	jekyll build --destination ~/jekyll/build
	git checkout develop
	git checkout --orphan release
	rm -rf *
	cp -a ~/jekyll/build/. ./
	git add -A
	git commit -m 'release'
	git checkout master
	git merge -s recursive -X theirs --squash --no-commit release
	git commit -am $(tag)
	git tag -a $(tag) -m $(tag)
	git branch -D release
	git checkout develop

	@echo ...Finished!

