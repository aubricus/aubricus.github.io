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

# ..example:
# 	 make release

.PHONY: release
release:
	@echo Creating release...

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
	git commit -am 'release $(shell date +"%Y-%d-%m %T")'
	git branch -D release
	git checkout develop

	@echo ...Finished!


# ..eample
# 	make deploy
.PHONY: deploy
deploy:
	git push origin master
