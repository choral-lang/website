---
layout: documentation
---

# Documentation

This is the Choral Reference Documentation.

First, please make sure to have [the compiler installed](/downloads) correctly
so that you can try all the examples listed in the documentation.

Once installed, the Choral compiler should be available as `choral` command.

## Choral version
You may check the Choral compiler version. If Choral is correctly installed, you
should see something like this:

```
$ java -jar choral --version
Choral 0.1
```

## Choral help
Now, if we want to list all the options supported by the compiler, we can run
choral without any argument:

```
$ java -jar choral
Usage: choral [-hqvV] [--debug] [--verbosity=<LEVEL>] [COMMAND]

Description:
A compiler for the choral programming language.
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

More details about using the compiler can be found on the manpage man crystal or
in our compiler manual.

## Hello Choral

You are ready to start using Choral, starting from its idiomatic 
[Hello Roles](/documentation/basics/hello_roles.html)