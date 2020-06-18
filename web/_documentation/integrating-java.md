---
layout: documentation
title: Integrating Java code
url: integrating-java
---

# Integrating Java code

Choral programs can reuse existing Java libraries (like the Java standard library).[^java-unsupported]
To use a Java class, interface, or enum inside of a Choral program, the Choral compiler requires a header file with suffix `.chh` (CHoral Header).
A header file defines the type of a foreign symbol, which can then be imported in Choral as if it were defined natively.

In the future, we plan to automate the generation of header files from Java classes. For now, you have to write your own headers manually (unless you need a Java symbol that is already supported by our preloaded headers, see [preloaded headers](#preloaded-headers)).

## Headers by example



## Preloaded headers

The Choral compiler comes already equipped with a few preloaded header files that make some common types from the Java standard library immediately available. For these types, you do not have to provide your own header. Contributions to this part are very welcome (this task could also be automated). You can see them at [https://github.com/choral-lang/choral/tree/master/src/main/resources/headers](https://github.com/choral-lang/choral/tree/master/src/main/resources/headers). A summary list is given at [https://github.com/choral-lang/choral/blob/master/src/main/resources/headers/standard.profile](https://github.com/choral-lang/choral/blob/master/src/main/resources/headers/standard.profile).


[^java-unsupported]: Arrays, nested classes, and wildcards in generics are not supported yet.