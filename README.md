# LaTeX templates

> **Important**
> The templates are currently a WIP

Templates for LaTeX document builds in Nix environments.

## About

These templates provide Nix development environments
for the reproducible build of LaTeX documents.
Each template lies in its own subdirectory.

Although they are Nix flake templates,
they also include `Justfile` and `.latexmkrc`
configuration files required for document build.
Therefore,
they can be used as templates by non-Nix users,
even though template system (like GitHub's)
generally favor a one-template-per-repository approach.
In the future,
[copier] integration (or alternative) may be implemented
to simplify the use of these templates for non-Nix users.

[copier]: https://copier.readthedocs.io

## Supported repository structure

All templates provide a Nix environment for compiling a LaTeX project
with the following structure:

1. Each project can contain multiple documents.
   Each document is associated with a `.tex` source file
   located at the root of the project.
   All other `.tex` files (TikZ figures, `include` targets, etc.)
   are placed in subdirectories.
2. Compilation is carried out in the `./build` directory;
   all intermediate files are placed in this directory
   to maintain cleanliness at the root.
3. Compilation is performed via `latexmk` configured by a `.latexmkrc` file.
   This configuration files allow compilation to take place in `./build/`
   and manages all dependencies.
   Therefore,
   there is no need to use a Makefile,
   as all recipes are handled by `latexmk`.
   Consequently,
   a [Justfile][just] is used to execute the compilation commands.

Here is an example structure supported by the templates:

```tree
project-root/
│
├── document1.tex
├── document2.tex
├── figures/
│   ├── figure1.tex
│   ├── figure2.tex
│   └── ...
│
├── sections/
│   ├── section1.tex
│   ├── section2.tex
│   └── ...
│
├── build/
│   ├── document1.pdf
│   ├── document2.pdf
│   └── ...
│
├── .latexmkrc
├── Justfile
└── ...
```

[just]: https://github.com/casey/just

## Templates

- [`full-phiso`](./full-phiso): LaTeX builds with [φso][phiso],
  `bib2gls` and TikZ `externalize` support

[phiso]: https://github.com/loicreynier/phiso

## Usage

1. Create a Git repository, copy the template and enable environment

   ```shell
   mkdir project && cd project
   git init
   nix flake init --template github:loicreynier/latex-templates#<template>
   direnv allow
   # or alternatively
   # nix develop
   ```

2. Edit and/or add source files

   ```shell
   touch slides.tex
   vi main.tex
   vi slides.tex
   ```

3. Build documents

   ```shell
   just build
   # or alternatively
   # nix build
   ```

## Credits

These templates are inspired by:

- Exploring Nix Flakes: Build LaTeX Documents Reproducibly by [flix]
- [benide/reproducible-latex](https://github.com/benide/reproducible-latex)

[flix]: https://flyx.org/nix-flakes-latex/
