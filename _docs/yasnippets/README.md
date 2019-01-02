# Yasnippets Collection

This folder contains a yasnippets collection with common templates
to ease the development.
Yasnippets can be integrated into Emacs: <https://github.com/joaotavora/yasnippet>.

The snippets can also be used to provide coding guidelines and
ensure a general look and feel.

## Quickstart

Copy the folders in this directory into your local yasnippets emacs configuration.

### General

* `~/.emacs.d/snippets`

### Spacemacs

* `~/.emacs.d/private/snippets`

## Usage

Use the `key` provided in the snippet and let yasnippet expand it.
Note:
Since yasnippet uses the actual mode of the file
which should be expanded ensure the mode and the snippets folder name match.

### Example: Makefile Generation

This requires the `makefile-gmake-mode` to be active as major mode.

1. Create `Makefile`
1. Type `mdoc`
1. Execute `yas-expand`
1. Use `TAB` to step through the template instantiation.
