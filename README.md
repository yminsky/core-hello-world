Hello World for Core
====================

A simple hello-world project for Core.  The intent is to show you how
to get started building OCaml projects using OPAM, Core and
OCamlbuild.  To use this, first get OPAM, and install the "core"
package.  Also, it's probably doing this:

    $ opam switch ocaml-4.00.1+short-types

to get better error messages from the compiler when using Core.  (As
of 4.01, this compiler variant should be obsolete.)

You can build all the pieces of this project by running:

    $ ./build_all.sh

Or you can build any individual executable by running

    $ ./build.sh hello_world.native

There are three basic examples

Hello World
-----------

This executable is `hello_world.native` (or `hello_world.byte`), and
here's an example of it in action.

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


Hello World client/server
-------------------------

The next example is a pair of programs: `hello_server.native` and
`hello_client.native`.  The server will accept requests via the
`Async.Rpc` library, and the client dispatches them.  The RPC is
trivial: the client sends a string, and the server attaches " World!"
to the end of it and sends the result back.

Message Broker
--------------

This is the most complicated example.  `broker_server.native` is a
simple message broker that allows you to publish and subscribe to
streams of data.  `broker_client.native` is a client that lets you do
a few operations, including publishing, subscribing, getting a dump of
the current state of the server, and shutting the server down.

Guide to the files
------------------

These are listed in rough dependency order.

* `hello_world.ml`: Command-line tool that prints "Hello World!"
* `common.ml`: Some common utilities for setting up Async-RPC clients
  and servers
* `hello_server.ml`: Async-RPC server for answering "hello" query
* `hello_client.ml`: Async-RPC client fro sending "hello" query
* `directory.ml`: Core datastructur of the Async message broker
* `broker_server.ml`: Async-RPC server that handles message broker
  requests.  Backed by the Directory.
* `broker_client.ml`: Async-RPC client that can publish, subscribe,
  get a dump of the state of the broker, and shut the broker down.

Plus, the build scripts:

* `_tags`: which sets up the build options for `ocamlbuild`.
* `build.sh`: For building any target, invoking `ocamlbuild`.
* `build_all.sh`: builds _all_ the executable targets.  Calls out to
  `build.sh`.


Setting up the toplevel
-----------------------

There's also a file called dot_ocamlinit, which will auto-load Core
for you in the toplevel, if you do this:

    $ cp dot_ocamlinit ~/.ocamlinit

If you want to use the toplevel, you might want to try installing
rlwrap to give you command-line editing, at which point you can run:

    $ rlwrap ocaml

and start using Core in the OCaml toplevel.
