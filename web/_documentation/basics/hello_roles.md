---
layout: documentation
title: Hello Roles
parent: Basics
url: basics/hello_roles
---

# Hello Roles

## Syntax 

The syntax of Choral is heavily inspired by one of the most widely-used mainstream languages: Java. Thus, Java developers (and akin, like C++/#) benefit from a graceful learning curve to grasp the main concepts of the Choral language. 

```choral
class MyExample@( Server, Client, Logger ) {
 
 Channel< String >@( Server, Logger ) logChannel;
 Log@Logger log;

 MyExample( Channel< String >@( Server, Logger ) logChannel, Log@Logger log ){
    this.logChannel = logChannel;
    this.log = log;
 }

 void sendMessage( Channel@( Server, Client ) channel ) {
  String@Server message = channel.com( Panel@Client.prompt( "Insert the message for the server" ) );
  log.record( logChannel.com( message ) );
  System@Server.out.println( "Client sent: "@Server + message );
 }
}
```

Choral extends the Java type system with the concept of worlds (from [hybrid logic](https://en.wikipedia.org/wiki/Hybrid_logic)). Worlds in Choral represent separate execution nodes or endpoints (which we use as a synonym for worlds). In the MyExample class, the traditional Client and Server represent endpoints, as well as the third-party Logger.

Choral objects are therefore always located at one world, e.g., `String@( Client )` --- shortened in `String@Client` --- or distributed among two or more worlds, e.g., `MyExample@( Server, Client, Logger )`.

Briefly, the program above:

- defines a class, called `MyExample`, which is distributed among three worlds, named Server, Client, and Logger;
- the class has two fields:
   - `logChannel`: a communication `Channel` between the Server and the Logger endpoints. The Choral runtime library provides different implementations of `Channel`s, e.g., using local memory, sockets, local files, and their encrypted counterparts. Choral `Channel`s also specify what type of data they can transmit safely. While in our example we restrict valid `Channel` implementations to just transmit `String`s, the Choral runtime library includes a set of `Channel` implementations able to safely transmit (serialize and deserialize) generic `Object`s (e.g., using [Google gson](https://github.com/google/gson) or [Kyro](https://github.com/EsotericSoftware/kryo));
   - `log`: a Log object used for persistent logging, owned by the Logger endpoint.
- the class has a method `sendMessage`, which takes as a parameter a `Channel` between the Server and the Client. Then, when the Client inputs a message (acquired through the `prompt` method, a courtesy utility provided by the Choral runtime), its content is sent to the Server (through the `com` method of the `channel` object). Finally, the Server first transmits the received message to the Logger, for recording, and prints out the content of the message to its `System` output.

## Compilation

To run the example above, we first need to compile it into Java classes using the Choral compiler.

Assuming we saved the Choral program above in a file called `MyExample.ch`, we can launch the Choral compiler with the command <kbd>java -jar choral.jar MyProgram.ch</kbd>.

The result of the compilation is a set of well-formatted Java classes, each implementing the part of the program relative to a specific endpoint. In our example, we will obtain three files: `MyExample1.java`, `MyExample2.java`, and `MyExample3.java`, respectively corresponding to the implementation of the program for the first, second, and third endpoint (starting from the left-most one, in order of declaration).

Conveniently, single-world classes, like `String@Client` and `System@Server`, are not translated into `String1` and `System1` but directly into their Java counterparts (`String` and `System`), providing a lightweight mechanism for integrating Choral programs into any pre-existing Java ecosystem.

As an example, in `MyExample1.java` (corresponding to the implementation of the `MyExample` Choral class for the Server endpoint) we obtain:

```java
public class MyExample1 {
 
 Channel1< String > logChannel;
 Unit log;

 public MyExample1( Channel1< String > logChannel, Unit log ){
    this.logChannel = logChannel;
    this.log = log;
 }

 public void sendMessage( Channel1< String > channel ) {
  String message;
  message = channel.com( Unit.id );
  log.id( logChannel.com( message ) );
  System.out.println( "Client sent: " + message );
 }
}
```

Notably, fields and parameters (e.g., `log`) not belonging to the endpoint become objects of type `Unit`. `Unit` is a special class provided by the Choral runtime that allows Choral-compiled programs to closely preserve their original structure. `Unit` also supports the execution of side-effects in chained expressions --- e.g., the expression `log.id(logChannel.com(message))`, where the method `id` supports the evaluation of the arguments of the original method call (`log`). In this case, it executes the sending of the `message` to the logger.

Dually, `MyExample3.java` is the implementation relative to the Logger: 

```java
public class MyExample3 {
 
 Channel2 logChannel;
 Log log;

 public MyExample3( Channel2 logChannel, Log log ){
    this.logChannel = logChannel;
    this.log = log;
 }

 public void sendMessage( Unit channel ) {
  String message;
  message = channel.id;
  log.record( logChannel.com( message ) );
 }
}
```

Notable elements here are:

- the Logger owns the "other end" of the Channel shared with the Server (logChannel as `Channel2`);
- the removal of irrelevant effects for the endpoint, e.g., 
  the statement `System@Server.out.println( "Client sent: "@Server + message );` which contains no elements relative to the Logger.

## Execution

Once we obtained the Java classes that implement our Choral program, we can run the compiled system.

To briefly demonstrate how this can be done, in the example below we write a dedicated Java class that uses in-memory channels provided by the Choral runtime, called `LocalChannel`s (`LocalChannel1` and `LocalChannel2`). In this case, the endpoints represent separate, concurrent `Thread`s in the same machine.

```java
ByteChannel a1, a2, b1, b2;
PipeChannel.connect( a1, a2 );
PipeChannel.connect( b1, b2 );
MyExample1 server = new MyExample1( new LocalChannel1( a1 ), Unit.id );
MyExample2 client = new MyExample2( Unit.id, Unit.id );
MyExample3 logger = new MyExample3( new LocalChannel2( a2 ), new Log() );
new Thread().run( () => server.sendMessage( new LocalChannel1( b1 ) ) );
new Thread().run( () => client.sendMessage( new LocalChannel2( b2 ) ) );
new Thread().run( () => logger.sendMessage( Unit.id ) );
```