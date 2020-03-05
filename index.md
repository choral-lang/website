---
layout: home
---

Starting tour: [Installation](#installation) > [Syntax](#syntax) > [Compilation](#compilation) > [Execution](#execution)

[Advanced Examples](#advanced_examples)

## Installation

- Download the jar file
- Run <kbd>java -jar choral.jar MyProgram.ch</kbd>

## Syntax 

The syntax of Choral is heavily inspired by one of the most widely-used mainstream languages: Java, so that Java developers (and akin, like C++/#) benefit from a graceful learning curve to grasp the main concepts of the Choral language. 

```choral
class MyExample@( Server, Client, Logger ) {
 
 Channel@( Server, Logger ) logChannel;
 Log@Logger log;

 MyExample( Channel@( Server, Logger ) logChannel, Log@Logger log ){
    this.logChannel = logChannel;
    this.log = log;
 }

 static void sendMessage( Channel@( Server, Client ) channel ) {
  String@Server message;
  message = channel.com( Panel@Client.prompt( "Insert the message for the server" ) );
  log.record( logChannel.com( message ) );
  System@Server.out.println( "Client sent: " + message );
 }
}
```

Choral extends the Java type system with the concept of worlds (from [hybrid logic](https://en.wikipedia.org/wiki/Hybrid_logic)). Worlds in Choral represent separate execution nodes or endpoints, as exemplified by the traditional Client-Server endpoints (to which we added a third-party Logger) in the class MyExample above. 

Choral objects are therefore always located at one world, e.g., `String@( Client )` --- shortened in `String@Client` --- or distributed among two or more worlds, e.g., `MyExample@( Server, Client, Logger )`.

Briefly, the program written above defines a class, called `MyExample`, which is distributed among three worlds, named Server, Client, and Logger. 

MyExample has two fields: 

- `logChannel`: a communication `Channel` between the Server and the Logger endpoints. The Choral runtime provides different implementation of `Channel`s, e.g., using local memory, sockets, local files, and their encrypted counterparts;
- `log`: a Log object used for persistent logging, owned by the Logger endpoint.

The `sendMessage` method takes as a parameter a `Channel` between the Server and the Client. Then, when the Client inputs a message (acquired through the `prompt` method, a courtesy utility provided by the Choral runtime), its content is sent to the Server (through the `com` method of the `channel` object).

Finally, the Server first transmits the received message to the Logger, for recording, and prints out its content.

## Compilation

To run the program we wrote above, we use the Choral compiler, which produces a set of Java classes, each implementing the behaviour of a specific endpoint.

Assuming we saved the Choral program above in a file called `MyExample.ch`, we can launch the 
Choral compiler with the command <kbd>java -jar choral.jar MyProgram.ch</kbd>.

The choral compiler will produce a set of  well-formatted Java classes, each implementing the part of the program relative to a specific endpoint. In our example, we will obtain three files: `MyExample1.java`, `MyExample2.java`, and `MyExample3.java`, respectively corresponding to the implementation of the program for the first, second, and third endpoint.

As an example, in `MyExample1.java` (corresponding to the implementation of the `MyExample` Choral class for the Server endpoint) we obtain:

```java
public class MyExample1 {
 
 Channel1 logChannel;
 Unit log;

 public MyExample( Channel1 logChannel, Unit log ){
    this.logChannel = logChannel;
    this.log = log;
 }

 public static void sendMessage( Channel1 channel ) {
  String message;
  message = channel.com( Unit.id );
  log.id( logChannel.com( message ) );
  System.out.println( "Client sent: " + message );
 }
}
```

Notably, fields and parameters (e.g., `log`) not belonging to the endpoint become objects of type `Unit`. `Unit` is a special class provided by the Choral runtime that allows Choral-compiled programs to closely preserve their original structure and supports the execution of side-effects in chained expressions --- e.g., the expression `log.id(logChannel.com(message))`, where the method `id` supports the evaluation of the arguments of the original method call (`log`). In this case, it executes the sending of the `message` to the logger.

Dually, `MyExample3.java` is the implementation relative to the Logger: 

```java
public class MyExample3 {
 
 Channel2 logChannel;
 Log log;

 public MyExample( Channel2 logChannel, Log log ){
    this.logChannel = logChannel;
    this.log = log;
 }

 public static void sendMessage( Unit channel ) {
  String message;
  message = channel.id;
  log.record( logChannel.com( message ) );
 }
}
```

Notable elements here are:

- the Logger owns the "other end" of the Channel shared with the Server (logChannel as `Channel2`);
- the removal of irrelevant effects for the endpoint, e.g., the `Unit`-converted call to `println` at the Client at the end of the `sendMessage` method.

## Execution

Once we obtained the Java classes that implement our program, we can run the compiled system.

To do that, in the example below we use the `LocalChannel`s (`LocalChannel1` and `LocalChannel2`) provided by the Choral runtime. To represent the distinct endpoint, we use three separate `Thread`s.

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