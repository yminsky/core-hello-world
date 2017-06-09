Core and Async Hello World
==========================

A simple hello-world project for using Core and Async.  The intent is
to show you how to get started building OCaml projects using
[opam](http://opam.ocaml.org),
[core](https://github.com/janestreet/core), 
[async](https://github.com/janestreet/async),
and [jbuilder](https://github.com/janestreet/jbuilder).

We assume that you can install OCaml and opam on your platform. You'll
need to install async, core, and textutils:

    $ opam install async core textutils

If you're using Merlin, you also might want to pin to the latest
version:

    $ opam pin add merlin --dev-repo

And you should consider installing the `user-setup` package to set up
your editor configs to use Merlin properly. This will give you
interactive feedback on compilation failures, type-throwback and
auto-completion.

Once that's done, you can build all the pieces of this project by
running:

    $ ./build_all.sh

Or you can build an individual file by calling out to jbuilder
directly

    $  jbuilder build hello_world.exe

There are three basic examples.

Hello World
-----------

This is a very simple exercise that shows you how to make a basic
command-line application using Core's `Command` module.

This executable is `hello_world.exe` (or `hello_world.bc`, for
bytecode), and here's an example of it in action.

    core-hello-world $ ./hello_world.exe
    Hello World!
    core-hello-world $ ./hello_world.exe -help
    Hello World

      hello_world.exe

    === flags ===

      [-hello]       The 'hello' of 'hello world'
      [-world]       The 'world' of 'hello world'
      [-build-info]  print info about this build and exit
      [-version]     print the version of this build and exit
      [-help]        print this help text and exit
                     (alias: -?)

    core-hello-world $ ./hello_world.exe -hello "Goodbye" -world "Yellow Brick Road"
    Goodbye Yellow Brick Road!


Hello World client/server
-------------------------

The next example is a pair of programs: `hello_server.exe` and
`hello_client.exe`.  The server will accept requests via the
`Async.Rpc` library, and the client dispatches them.  The RPC is
trivial: the client sends a string, and the server attaches " World!"
to the end of it and sends the result back.

Message Broker
--------------

This is the most complicated example.  `broker_server.exe` is a
simple message broker that allows you to publish and subscribe to
streams of data.  `broker_client.exe` is a client that lets you do
a few operations, including publishing, subscribing, getting a dump of
the current state of the server, and shutting the server down.

Setting up the toplevel
-----------------------

You can use the built-in OCaml toplevel, `ocaml`, but you're probably
better off using `utop`, which you can install via opam:

    $ opam install utop

There's also a file called dot_ocamlinit, which will auto-load core
and async, if you do this:

    $ cp dot_ocamlinit ~/.ocamlinit

And now you can start the toplevel.

    $ utop

