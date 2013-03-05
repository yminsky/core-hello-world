#!/usr/bin/env bash

eval `opam config -env`

ocamlbuild -j 4 -use-ocamlfind -cflags "-w @A-4-33-23" -cflags -short-paths $*


