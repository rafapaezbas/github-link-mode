# Github-link-mode

Minor Emacs mode that provides keybindings to generate a github url from a line,region or file and copies the link to the clipboard

## Installation

This package require [Projectile](https://github.com/bbatsov/projectile/) and Emacs 24.4.

package.el:

```
(package! github-link-mode
  :recipe (:host github :repo "rafapaezbas/github-link-mode"))
```

config.el:

```
(use-package github-link-mode)
```

## Usage

This minor mode will enable on projectile projects with a `.github` folder in the root.

`C-c g l` Copies region/line github url to clipboard.
`C-c g f` Copies file github file url to clipboard.
