---
layout: home
title: Install
---

# Install Choral

**Note on prerequisites.** Choral requires Java 14 or later. Choral can be installed in Linux, macOS, and Windows (through WSL) OSes.

## Default directories (fastest method)

To install Choral, paste and run the following command in a terminal.

<pre class="border p-2 bg-light">bash -c "$(curl -fsSl https://raw.githubusercontent.com/choral-lang/choral/master/scripts/install.sh)"</pre>

By default, this will install the `choral` executable launcher in `/usr/local/bin` and the Choral libraries in `/usr/local/lib/choral`.

You might need to run the command above using `sudo` if your user cannot write in `/usr/local` (or you can set custom directories, see below).

## Custom directories

If you want to choose different installation directories, just pass them as arguments to the install script as follows.

<pre class="border p-2 bg-light">bash -c "$(curl -fsSl https://raw.githubusercontent.com/choral-lang/choral/master/scripts/install.sh)" -s -l /path/to/store/the/launcher -ch /path/to/store/choral/libraries</pre>

For example, to install the `choral` launcher in `~/bin` and the Choral libraries in `~/bin/choral-dist`, use the following.

<pre class="border p-2 bg-light">bash -c "$(curl -fsSl https://raw.githubusercontent.com/choral-lang/choral/master/scripts/install.sh)" -s -l ~/bin -ch ~/bin/choral-dist</pre>

## Manual installation

To manually install Choral, follow the steps below:
- [download the latest release](https://github.com/choral-lang/choral/releases/latest) from the Github repository;
- unzip the ZIP archive, which will give you the subdirectories `launchers` and `dist`;
- move all files inside `launchers` to a directory in your `$PATH`;
- set the environment variable `CHORAL_HOME` to a directory of your choice (this is the directory where we will install the Choral libraries);
- move all files (and subdirectories) inside `dist` to the directory pointed at by `CHORAL_HOME`.


# Choral commands

## Choral version

You should be able to check Choral's version by running the following command.

```
$ choral --version
Choral 0.1 (C) 2020 the Choral team
```

## Command line help

To list all the options supported by the compiler, you can
choral without any argument.

```
$ choral
Usage: choral [-hqvV] [--debug] [--verbosity=<LEVEL>] [COMMAND]

Description:
A compiler for the Choral programming language.
https://choral-lang.org/

Options:
      --verbosity=<LEVEL>   Verbosity level: ERRORS, WARNINGS, INFO, DEBUG.
  -v, --verbose             Enable information messages.
  -q, --quiet               Disable all messages except errors.
      --debug               Enable debug messages.
  -h, --help                Show this help message and exit.
  -V, --version             Print version information and exit.

Commands:
  check, c                  Check correctness and projectability.
  endpoint-projection, epp  Generate local code by projecting a choreography at
                              a set of roles.
  headers, chh              Generate choral header files (.chh).
  generate-completion       Generate bash/zsh completion script for choral.
```

## Some key commands

For each command, you can get help by invoking the `-h` or `--help` option.
For example, to get help on how to use the `epp` command (for compiling Choral code to Java), invoke `choral epp -h`.

Here's a brief overview of the main commands.

- Use `choral epp ChoralName` to compile the Choral interface or class `ChoralName` to Java.
- Use `choral check ChoralName` to check that the Choral interface or class `ChoralName` is well-typed and can be compiled.


# IDE support

We do not have an easy-to-install IDE plugin for Choral yet. (See? We're really a prototype!)

If you're interested in making one: the first line of output messages printed by `choral check` follows the same format of `javac`, so it should be possible to adapt an existing Java plugin. Here is an output example.

```
ConsumeItems.ch:11:6: error: Cannot resolve method 'select(choral.example.ConsumeItems.ConsumeChoice@(B))' in 'choral.channels.DiChannel@(A,B)<java.lang.Integer>'.

   10 |     if ( it.hasNext() ){
   11 |       ch.< ConsumeChoice >select( ConsumeChoice@B.AGAIN );
      | ---------^
   12 |       it.next() >> ch::< Integer > com >> consumer::accept;
```
