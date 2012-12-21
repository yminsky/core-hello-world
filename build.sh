#!/usr/bin/env bash

eval `opam config -env`

for TARGET in $*
do
  ocamlbuild -use-ocamlfind $TARGET -cflags "-w @A-4-33-23"
done


