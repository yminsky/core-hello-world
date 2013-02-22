Hello World for Core
====================

A simple hello-world project for Core.  The intent is to show you how
to get started building OCaml projects using OPAM, Core and
OCamlbuild.  To use this, first get OPAM, and install the "core"
package.  Also, it's probably doing this:

    $ opam switch ocaml-4.00.1+short-types

to get better error messages from the compiler when using Core.  (As
of 4.01, this compiler variant should be obsolete.)

You can build the project by running:

    $ ./build.sh hello_world.native

and you can then use it as follows:

    core-hello-world $ ./hello_world.native
    Hello World!
    core-hello-world $ ./hello_world.native -help
    Hello World

      hello_world.native

    === flags ===

      [-hello]       The 'hello' of 'hello world'
      [-world]       The 'world' of 'hello world'
      [-build-info]  print info about this build and exit
      [-version]     print the version of this build and exit
      [-help]        print this help text and exit
                     (alias: -?)

    core-hello-world $ ./hello_world.native -hello "Goodbye" -world "Yellow Brick Road"
    Goodbye Yellow Brick Road!

There's also a file called dot_ocamlinit, which will auto-load Core
for you in the toplevel, if you do this:

    $ cp dot_ocamlinit ~/.ocamlinit

If you want to use the toplevel, you might want to try installing
rlwrap to give you command-line editing, at which point you can run:

    $ rlwrap ocaml

and start using Core in the OCaml toplevel.
