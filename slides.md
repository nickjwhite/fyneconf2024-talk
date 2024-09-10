---
title: Advanced cross-platform packaging with Fyne
subtitle: |
    \
    https://github.com/nickjwhite/fyneconf2024-talk
author: Nick White
date: 2024-09-20
aspectratio: 169
theme: metropolis
toc: true
toc-title: Contents
---

# Caveat

I haven't used `fyne-cross` before

Some of the things I discuss may be better solved with that.

Let me know!

# Rescribe

OCR software I developed a few years ago, and maintain.

https://rescribe.xyz/rescribe | https://github.com/rescribe/bookpipeline

Look in the `cmd/rescribe` directory

![Screenshot](screenshot.png){width=50%}

# Creating a universal binary for Mac

See `cmd/rescribe/makefile`

First compile the amd64 & arm64 versions (`osxcross` / `fyne-cross`)

	CC="o64-clang" GOOS=darwin GOARCH=amd64 go build -o rescribe-amd64 .
	CC="oa64-clang" GOOS=darwin GOARCH=arm64 go build -o rescribe-arm64 .

Then use `lipo` to combine them:

	lipo -create rescribe-amd64 rescribe-arm64 -output rescribe

Then use `fyne package` to create the .app, and `codesign` to sign it.

	fyne package --release --certificate Rescribe --id xyz.rescribe.rescribe \
	  --name Rescribe --exe rescribe --os darwin --icon icon.png --appVersion 1.4.0
	codesign -s MyCert Rescribe.app

## Making codesign work

I don't know how to do this without a Mac, or on the command line.

- Open Keychain Access
- Keychain Access -> Certificate Assistant -> Create Certificate
- Enter a name (you pass this to `-s myname` in the `codesign` command)
- Set "Certificate Type" to "Code Signing"

# Embedding native binaries

Can cross-compile other binaries and pick the appropriate one using build constraints.

	embed_windows.go
	//go:embed tesseract-w32.zip
	var tesszip []byte

	embed_darwin_arm64.go
	//go:embed tesseract-osx-m1.zip
	var tesszip []byte

	embed_other.go
	//go:build (!darwin && !windows)
	var tesszip []byte

Can unpack whatever is in `tesszip` into a temporary directory and call the appropriate command, or skip this step if it's empty.

These zip files can be downloaded with `go generate`.

## Making these embedded binaries work

Dynamically compiled binaries are can be hard make portable.

Need to make them look in their directory for the libraries they load in.

Windows binaries already do this by default, so just find any .dlls and put them there.

Linux binaries can often be easily rebuild statically.

Mac is a pain...

## Making these embedded binaries work on Mac

First find all the .dylib files it needs:

	otool -L tesseract
	otool -L libname.dylib

Then set them to look in the same directory as the parent, for libraries linked to executable and other libraries.

	install_name_tool -change /usr/local/opt/libpng/lib/libpng16.16.dylib \
	  @executable_path/libpng16.16.dylib liblept.5.dylib

Then re-sign the executables and libraries:

	codesign -f -s - liblept.5.dylib

Is there an easier way to do this?

## Making these embedded binaries work

And of course, this has to be done on every architecture you want to support.

# Linux packaging with Flatpak

-------

# notes:

mostly about good packaging

haven't used fyne-cross, but this should be handy regardless

intro to rescribe

osx creating a binary containing arm64 & amd64. codesign

using embed to include natively compiled binaries
- windows making dlls static
- again creating multiarch osx binaries
- keeping go get still working by having sane fallbacks

flatpak & flathub. wayland, desktop portals. thank jakob
- need to create vendor
- a script to pick xorg / wayland

potential improvements to fyne package / fyne cross

