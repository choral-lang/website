---
layout: documentation
title: Interaction
parent: Basics
ancestor: Documentation
url: basics/interaction
---

# Interaction

Choral programs become interesting when they contain interaction between roles&mdash;otherwise, they are a simple interleaving of local independent behaviours by different roles, as in [HelloRoles](/documentation/basics/hello_roles.html).

Thanks to our data types parameterised over roles, Choral can define 
as objects also the basic building blocks for interaction, e.g., sending a value from a role to another over a channel, and then construct more complex interactions compositionally. 

This allows Choral to be specific about the requirements of choreographies regarding communications, leading to more reusable code. 

For instance, if a choreography needs only a directed channel, then our type system can see by subtyping that a bidirectional channel is also fine. 

## Directed data channels

We start our exploration of interaction in Choral from simple directed channels for transporting data. In Choral, this is an object that takes data from one place to another. We specify this as an interface.

```choral
interface DiDataChannel@( A, B )< T@X > { 
  < S@Y extends T@Y > S@B com( S@A m ); 
}
```

A `DiDataChannel` is the interface of a directed channel between two roles, abstracted by `A` and `B`, that can transfer data of type `T`. 

The method `com` takes any subtype of `T` located at `A`, `S@A`, and returns a value of type `S@B`. Parameterising data channels over the type of transferrable data (`T`) is important in practice for channel implementors because they often need to deal with data marshalling. 

Choral comes with a standard library that offers implementations of our channel APIs for a few common types of channels, e.g., TCP/IP sockets supporting JSON objects and shared memory channels and users can provide their own implementations.

Using a `DiDataChannel`, we can write a simple method that sends a string notification from a `Client` to a `Server` and logs the reception by printing on screen.

```choral
notify( DiDataChannel@( Client, Server )< String > ch, String@Client msg ){ 
  String@Server m = ch.com< String >( msg ); 
  System@Server.out.println( m ); 
}
```

Note that `String` is a valid instantiation of `T@X` of `DiDataChannel` because we lift all Java types as Choral types parameterised over a single role.

## Alien Data Types

Compiling `DiDataChannel` to Java poses an important question: 

<div class="text-center bg-warning col-6 mx-auto">
what should be the return type of method com in the code produced for role `A`? 
</div>

Since the return type does not mention `A` (we say that it is alien to `A`), a naïve answer to this question could be `void`, as follow `interface DiDataChannel_A<T> { <S extends T> void com(S m); }`. It turns out that this solution does not work well with expressions that compose multiple method calls, including chaining like `m1( e1, e2 ).m2( e3 )` and nesting like `m1( m2( e ) )`. As a concrete example, consider a simple round-trip communication from `A` to `B` and back.

```choral
static < T@X > T@A roundTrip( 
  DiDataChannel@( A, B )< T > chAB, 
  DiDataChannel@( B, A )< T > chBA, 
  T@A mesg ) { 
  return chBA.com< T >( chAB.com< T >( mesg ) ); 
}
```

Method `roundTrip` takes two channels, `chAB` and `chBA`, which are directed channels respectively from `A` to `B` and from `B` to `A`. The method sends the input `mesg` from `A` to `B` and back by nested coms and returns the result at `A`.
A structure-preserving compilation of method `roundTrip` for role `A` would be as follows.

```java
static < T > T roundTrip (
  DiDataChannel_A< T > chAB, 
  DiDataChannel_B< T > chBA,
  T mesg ) { 
    return chBA.com< T >( chAB.com< T >( mesg ) ); 
}
```

Observe how the inner method call, `chAB.com< T >( mesg )`, should return something, such that it can trigger the execution of the outer method call to receive the response. Therefore, the `com` method of `DiDataChannel_A` cannot have `void` as return type.

Programming language experts have probably guessed by now that the solution is to use `Unit` values instead of `void`. Indeed, Choral defines a singleton type `Unit`, a final class that the Choral compiler uses instead of `void` to obtain Java code whose structure resembles its Choral source code.

We now show the Java code produced by our compiler from `DiDataChannel` for both `A` and `B`.


<div class="row">
<div class="col-lg-6 col-12">
```java
interface DiDataChannel_A< T > { 
  < S extends T > Unit com( S m ); 
}
```
</div>
<div class="col-lg-6 col-12">
```java
interface DiDataChannel_B< T >{ 
  < S extends T > S com( Unit m ); 
}
``` 
</div>
</div>

Given these interfaces, the compilation of `roundTrip` for role `A` is well-typed and correct Java code. An alternative to using `Unit` would have been to give up on preserving structure in the compiled code. We chose in favour of `Unit`s because preserving structure makes it easier to read and debug the compiled code (especially when comparing it to the source choreography), and also makes our compiler simpler.

The users of Choral-compiled libraries are not forced to passing `Unit` arguments to methods, as for method `com` of `DiDataChannel_B`: for methods like these, our compiler provides corresponding
"courtesy methods" that take no parameters and inject `Unit`s automatically.

## Bidirectional channels

An immediate generalisation of directed data channels brings us to bidirectional data channels, specified by ``BiDataChannel``.

```choral
interface BiDataChannel@( A, B )< T@X, R@Y > extends 
  DiDataChannel@( A, B )< T >, 
  DiDataChannel@( B, A )< R > 
{}
```

A `BiDataChannel` is parameterised over two types: `T` is the type of data that can be transferred from `A` to `B` and, vice versa, `R` is the type of data that can be transferred in the opposite direction. This is obtained by multiple type inheritance: `BiDataChannel` extends `DiDataChannel` in one and the other direction, which allows for using modularly a bidirectional data channel in code that has the weaker requirement of a directed data channel in one of the two supported directions.

Distinguishing the two parameters `T` and `R` is useful for protocols that have different types for requests and responses, like HTTP. We discuss more types of channels (including symmetric channels) in the documentation page dedicated to [Channels](/_documentation/basics/channels.html).

## Forward chaining

We use bidirectional channels to define a choreography for remote procedure calls, called RemoteFunction, which leverages the standard Java interface `Function< T, R >`.

```choral
class RemoteFunction@( Client, Server )< T@X, R@Y > {
  
  private BiDataChannel@( Client, Server )< T, R > ch; 
  private Function@Server< T, R > f; 
  
  public RemoteFunction( 
    BiDataChannel@( Client, Server )< T, R > ch, 
    Function@Server<T, R> f
  ){ 
    this.ch = ch; 
    this.f = f; 
  }

  public R@Client call( T@Client t ) { 
    return ch.< R >com( f.apply( ch.< T >com( t ) ) ); 
    } 
}
```

In the experience that we gained by programming larger Choral programs, compositions of method invocations including data transfers, as it happens within the `call` method of the `RemoteFunction` class, are rather typical. 

In these chains, data transfers are read from right to left (innermost to outermost invocation), but most choreography models in the literature use a left-to-right notation (as in "Alice sends 5 to Bob"). 

To make Choral closer to that familiar choreographic notation, we borrow the forward chaining operator `>>` from [F#](https://docs.microsoft.com/en-us/dotnet/fsharp/language-reference/symbol-and-operator-reference/), so that `exp >> obj::method` is syntactic sugar for `obj.method( exp )`. For example, we can rewrite method call of `RemoteFunction` as follows, which is arguably more readable and recovers a more familiar choreographic notation.

```choral
public R@Client call( T@Client t ){ 
  return t  >>  ch::< T >com  >>  f::apply  >>  ch::< R >com;
}
```