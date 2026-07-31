<div align="center">

# Definitely Not Papers, Please

*A tiny bureaucratic document-checking game built with Odin and raylib*

![Status](https://img.shields.io/badge/status-work%20in%20progress-yellow)
![Language](https://img.shields.io/badge/language-Odin-blue)
![Library](https://img.shields.io/badge/library-raylib-red)

</div>

---

## About

**Definitely Not Papers, Please** is a small document-inspection game inspired by *Papers, Please*.

You work at a border checkpoint, inspect documents, compare information, follow increasingly complicated rules, and decide who may enter.

This project is being developed for learning and experimentation with **Odin**, **raylib**, and low-level game development.

## Goals

The general idea is a small checkpoint-inspection loop: look at a document, compare it against the current rules, and stamp it approved or rejected. Beyond that, scope and direction are still taking shape as the project develops.

## Built With

* [Odin](https://odin-lang.org/) — programming language
* [raylib](https://www.raylib.com/) — graphics and game development library

## Getting Started

Make sure Odin is installed and available from your terminal.

Clone the repository:

```bash
git clone https://github.com/beratdogan6/definitely-not-papers-please.git
cd definitely-not-papers-please
```

Run the project:

```bash
./run.sh
```

Build an executable (output goes to `bin/`):

```bash
./build.sh
```

Both scripts just wrap the Odin toolchain (`odin run src`, `odin build src -out:bin/...`) and make sure they run from the repo root, since assets are loaded with paths relative to it.

## Project Structure

```text
definitely-not-papers-please/
├── assets/
├── src/
│   ├── main.odin       # entry point: window setup, main loop
│   ├── layout.odin     # quadrant layout and labels
│   ├── document.odin   # the draggable document
│   ├── queue.odin      # queue state, animation, and drawing
│   ├── booth.odin      # border booth, megaphone, "NEXT!" bubble
│   └── math_util.odin  # generic lerp/clamp/smoothstep helpers
├── build.sh
├── run.sh
├── README.md
└── .gitignore
```

All files under `src/` belong to the same Odin package (`package main`) — Odin packages are directory-based, so splitting a package across files is the idiomatic way to organize code, no cross-file imports needed. The structure will grow as new systems and assets are added.

## Disclaimer

This is an unofficial, non-commercial fan project created for educational purposes.

It is inspired by *Papers, Please*, created by Lucas Pope, but does not use its original source code, artwork, music, characters, or other game assets.

## License

No license has been selected yet.

---

<div align="center">

**Definitely not suspicious. Definitely not Papers, Please.**

</div>
