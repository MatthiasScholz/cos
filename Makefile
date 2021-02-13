.PHONY: test

test:
	cd test && make all

######################################################################
# Release Management
# Taken from: https://github.com/MatthiasScholz/demo_github_release
######################################################################
# NOTE Should be set when calling make
token_github :=
release_version ?= v0.4.0

# Extracting version information from the repository
fabio_file := examples/jobs/fabio.nomad
packer_file := modules/ami2/nomad-consul-docker-ecr.json

release_branch := releases/$(release_version)
today := `date +'%Y-%m-%d'`
release_notes_template := _docs/changelogs/CHANGELOG.template.md
release_notes_file := _docs/changelogs/CHANGELOG.$(release_version).md
release_title := "$(release_version) ($(today))"
# Extracting the information from the actual files in use
version_nomad := `cat $(packer_file) | jq '.variables.nomad_version' | tr -d '"'`
version_consul := `cat $(packer_file) | jq '.variables.consul_version' | tr -d '"'`
version_fabio := `cat $(fabio_file) | grep releases | sed -n "s/.*v\([0-9.]*\).*/\1/p"`
version_terraform := `grep --recursive --include=\*.tf "required_version" ./examples/root-example | sed -n "s/.* \([0-9.]*\).*/\1/p" | uniq`
version_tf_nomad := `grep --recursive --include=\*.tf "terraform-aws-nomad.git" ./modules | sed -n "s/.*v\([0-9.]*\).*/\1/p" | uniq`
version_tf_consul := `grep --recursive --include=\*.tf "terraform-aws-consul.git" ./modules | sed -n "s/.*v\([0-9.]*\).*/\1/p" | uniq`

release: release-commit release-push release-github
test-release: release-notes release-commit release-push release-github

# NOTE Ensure existing files are not overwritten
release-notes: $(release_notes_file)
$(release_notes_file):
	@echo "INFO :: Writting the Changelog: '$(release_notes_file)'"
	release_date=$(today) \
	release_version=$(release_version) \
	version_nomad=$(version_nomad) \
	version_consul=$(version_consul) \
	version_fabio=$(version_fabio) \
	version_terraform=$(version_terraform) \
	version_tf_nomad=$(version_tf_nomad) \
	version_tf_consul=$(version_tf_consul) \
	consul-template -once -template="$(release_notes_template):$(release_notes_file)"

	@echo "INFO :: Adding release to 'CHANGELOG.md'"
	@echo "" >> CHANGELOG.md
	@echo "## $(release_version) ($(today))" >> CHANGELOG.md
	@echo "" >> CHANGELOG.md
	@echo "- [release notes]($(release_notes_file))" >> CHANGELOG.md

release-commit:
	@git add .
	git commit -m ":pushpin: $(release_version)"

release-github:
	gh release create $(release_version) --draft --prerelease --title $(release_title) --notes-file $(release_notes_file) --target $(release_branch)
	@gh release list

release-push:
	git push origin main
	@git branch $(release_branch)
	git push origin $(release_branch)

gh-login:
ifeq ($(strip $(token_github)),)
	@echo "ERROR :: No github token given. Please call 'make' like this: 'make token_github=<put_github_token>'"
	@exit 1
endif
	echo $(token_github) | gh auth login --with-token
	gh auth status

setup:
	brew install consul-template
	brew install gh
	consul-template -version
	gh version

uninstall:
	brew uninstall consul-template
	brew uninstall gh
