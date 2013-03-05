# Installing OCaml

## MacOS X

The [Homebrew](http://github.com/mxcl/homebrew) package manager has an
OPAM installer, which is usually updated pretty quickly to the latest
stable release.  The Perl-compatible Regular Expression library (PCRE)
is used by the Core_extended suite, so you will want to install that
as well.

```
$ brew install ocaml
$ brew install pcre
```

Another popular package manager on MacOS X is [MacPorts](http://macports.org),
which also has an OCaml port:

```
$ port install ocaml
$ port install ocaml-pcre
```


## Debian Linux

On Debian Linux, you should install OCaml via binary packages.  You'll
need at least OCaml version 3.12.1 to bootstrap OPAM, which means
using Debian Wheezy or greater.  Don't worry about getting the
absolute latest version of the compiler, as you just need one new
enough to compile the OPAM package manager, after which you use OPAM
to manage your compiler installation.

```
$ sudo apt-get install ocaml ocaml-native-compilers camlp4-extra
$ sudo apt-get install git libpcre3-dev curl build-essential m4
```

Notice that we've installed a few more packages than just the OCaml compiler
here.  The second command line installs enough system packages to let you
build your own OCaml packages.  You may find that some OCaml libraries require
more system libraries (for example, `libssl-dev`), but we'll highlight
these in the book when we introduce the library.

## Building from source

To install OCaml from source code, first make sure that you have a C compilation
environment (usually either `gcc` or `llvm` installed)

```
$ curl -OL http://caml.inria.fr/pub/distrib/ocaml-4.00/ocaml-4.00.1.tar.gz
$ tar -zxvf ocaml-4.00.1.tar.gz
$ cd ocaml-4.00.1
$ ./configure
$ make world world.opt
$ sudo make install
```

The final step requires administrator privilege to install in your
system directory.  You can also install it in your home directory by
passing the `prefix` option to the configuration script:

```
$ ./configure -prefix $HOME/my-ocaml
```

Once the installation is completed into this custom location, you will
need to add `$HOME/my-ocaml/bin` to your `PATH`, normally by editing
the `~/.bash_profile` file.  You shouldn't really to do this unless
you have special reasons, so try to install binary packages before
trying a source installation.

# Installing OPAM

**IMPORTANT**

    OPAM maintains multiple compiler and library installations, but
    this can clash with a global installation of the `ocamlfind` tool.
    Uninstall any existing copies of `ocamlfind` before installing
    OPAM.

OPAM manages multiple simultaneous OCaml compiler and library
installations, tracks library versions across upgrades, and recompiles
dependencies automatically if they get out of date.  It's used
throughout Real World OCaml as the mechanism to retrieve and use
third-party libraries.

Before installing OPAM, make sure that you have the OCaml compiler
installed as described above.  Once installed, the entire OPAM
database is held in your home directory (normally `$HOME/.opam`).  If
something goes wrong, just delete this `.opam` directory and start
over from a clean slate.  If youre using a version of OPAM you've
installed previously, please ensure you have at least version
0.9.3 or greater.


## MacOS X

Source installation of OPAM will take a minute or so on a modern
machine.  There is a Homebrew package for the latest OPAM:

```
$ brew update
$ brew install opam
```

And on MacPorts, install it like this:

```
$ port install opam
```

### Debian Linux

There are experimental binary packages available for Debian Wheezy/amd64. Just
add the following line to your `/etc/apt/sources.list`:

```
deb http://www.recoil.org/~avsm/ wheezy main
```

When this is done, update your packages and install OPAM.  You can ignore the
warning about unsigned packages, which will disappear when OPAM is upstreamed
into Debian mainline.

```
# apt-get update
# apt-get install opam
```

## From source

If the binary packages aren't suitable, you need to install the latest OPAM
release from source.  The distribution only requires the OCaml compiler
to be installed, so this should be pretty straightforward. Download the
latest version, which is always marked with a `stable` tag on the project
[homepage](https://github.com/OCamlPro/opam/tags).

```
$ curl -OL https://github.com/OCamlPro/opam/archive/latest.tar.gz
$ tar -zxvf latest.tar.gz
$ cd opam-latest
$ ./configure && make
$ sudo make install
```

# Setting up OPAM

The entire OPAM package database is held in the `.opam` directory in
your home directory, including compiler installations. On Linux and
MacOS X, this will be the `~/.opam` directory.  You shouldn't switch
to an admin user to install packages as nothing will be installed
outside of this directory.  *IMPORTANT*: If you run into problems,
just delete the whole `~/.opam` directory and follow the installations
instructions from the `opam init` stage again.

```
$ opam init
$ opam switch 4.01.0dev+trunk
```

The first command line gets OPAM up and running, the second one will
download and install a more up-to-date version of the compiler.  The
+short-types patch described above greatly improves error messages
that would be encountered with using Core and Async. (As of 4.01, this
compiler variant should be obsolete.)

You'll then need to install the necessary libraries to use this
example.  You can do that by typing:

```
# opam install async core_extended
```

When you're done here, look at the instructions in the README to see
what to do next.

