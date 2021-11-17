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

Suppose we want to write a Choral program where role `Alice` sends the greeting message `Hello from Alice` for role `Bod` to print on its console and the message can only be exchanged over a channel that transmits `ByteString`. Luckily, we have a Java library to handle serialisation and deserialisation to `ByteString` via the API in the fragment below.
```java
/* Java */
package library;

public class Serialiser {

  public static ByteString stringToBytes( String s ) { /* method body omitted */ }

  public static String stringFromBytes( ByteString s ) { /* method body omitted */ }

  /* other members omitted */

}
```
Intuitively, to lift a Java API to Choral we just need to "add" to every type one role parameter. For instance, the Java types `int` and `String` become `int@A` and `String@A` for some role `A` (the specific choice of name is irrelevant). Then, we could use `Serialiser` in our code like any class written in Choral as shown in the snippet below.
```choral
/* Choral */
import somelibrary.Serialiser;

public class Hello@( Alice, Bob ) {

  public static void run( 
    DiChannel<ByteString>@(Alice, Bob) channel   // direct ByteString channel from Alice to Bob
  ) {
    "Hello from Alice"@Alice                     // Alice's message
    >> Serialiser@Alice::stringToBytes           // is encoded into a ByteString
    >> channel::<ByteString>com                  // sent over the channel to BoB
    >> Serialiser@Bob::stringFromBytes           // that decodes the message
    >> System@Bob.out::println;                  // and prints it
  }

}
```
In order to check and project the code above, the Choral compiler needs to know that `Serialiser` has one role and two static methods `stringToBytes` and `stringFromBytes` as well as their signatures. Implementations of methods and constructors are not necessary.  To provide this information to the Choral compiler we need the following Choral Header.
```choral
/* Choral Header */
package some.library;

public class Serialiser@( A ) {

  public static ByteString@( A ) stringToBytes( String@( A ) s ) { 
    /* left empty, method and constructor bodies are ignored */
  }

  public static String@( A ) stringFromBytes( ByteString@( A ) s ) { 
    /* left empty, method and constructor bodies are ignored */
  }

}
```
This is precisely the fragment of the Java class `Serialiser` required by our program `Hello` where the Choral class `Serialiser` is parametrised in one role (`A`) and all types that appear in its definition are located at the same role. 

In general, a Choral Header is a file with the extension `.chh` that contains what is essentially Choral source code. Bodies of methods and constructors are ignored and thus usually left empty. 
Choral Headers written to represent Java APIs may omit part of it (in the example above, we write only `stringToBytes` and `stringFromBytes` in the header). 
It is the responsibility of the writer of the header to include all relevant information as the Choral compiler will be unaware of any information about Java code not written in the provided header files.

## Preloaded headers

The Choral compiler comes already equipped with a few preloaded header files that make some common types from the Java standard library immediately available. For these types, you do not have to provide your own header. Contributions to this part are very welcome (this task could also be automated). You can see them [here](https://github.com/choral-lang/choral/tree/master/choral/src/main/resources/headers). A summary list is given [here](https://github.com/choral-lang/choral/blob/master/choral/src/main/resources/headers/standard.profile).


[^java-unsupported]: Arrays, nested classes, raw types, and wildcards in generics are not supported yet.