---
layout: documentation
title: Hello Roles
parent: Basics
ancestor: Documentation
url: basics/hello_roles
---

# Hello Roles

Choral is an object-oriented language with statically-typed high-level abstractions for the programming of choreographies (multiparty protocols).

## Roles and types

In Choral, **choreographies are objects** (and objects are choreographies). Choral objects have types of the form `T@(R1, ..., Rn)`, where `T` is the usual interface of the object, and `R1, ... , Rn` are the roles that collaboratively implement the object.
The state and behaviour of an object can be distributed over the roles of its type, which is the key feature that allows us to express choreographies.

<!-- 
All values in Choral are distributed over one or more roles using the `@`-notation, e.g., `String@Alice` declares a `String` (as in Java) but located at some endpoint, abstracted by the role `Alice`. Roles are part of data types in Choral, adding a new dimension to typing.
With roles, Choral can express that an object is implemented "choreographically", i.e., that

- its state (represented by its fields) is distributed among a set of roles;
- and its methods include behaviour specific to each of its roles.
-->

Values in Choral must be located at roles as well.
For example, the literal `"Hello"@A` is a string value `"Hello"` located at role `A`. All existing Java types can be used in Choral as types that live at a single world (like the string `"Hello"` here).

<!-- 
The degenerate case of values involving one role (as in `String@Role`) allows Choral to reuse existing Java classes and interfaces, lifted mechanically to Choral types and made available to Choral code.
-->

Code involving different roles can be freely mixed in Choral, as in the following snippet.


```choral
class HelloRoles@(A, B) {
   public static void sayHello() {
      String@A a = "Hello from A"@A; 
      String@B b = "Hello from B"@B; 
      System@A.out.println(a); 
      System@B.out.println(b); 
   }
}
```

<p class="text-center text-monospace">
Try it yourself: see the [source code](https://github.com/choral-lang/examples/tree/master/choral/hello-roles) on <i class="fab fa-github"></i>.
</p>

The code above defines a class, `HelloRoles`, parameterised over two roles, `A` and `B`.
<!-- The example is useful to show that the single-role notation seen before, e.g., `String@Role` is syntactic sugar for `String@(A)` where the full `@(...)` notation surrounds the declaration of the (singleton) list of roles of that data type. -->
Its method `sayHello` defines a variable `a` of type "String at A" (`String@A`) to which we assign the value `"Hello from A"` located at `A` (`"Hello from A"@A`).
Similarly, we define and assign a value to a variable `b` as a string located at `B`.

In the last two lines of the method, we print variable `a` by using the `System` object at `A` (`System@A`), and then we print variable `b` at role `B`.

Roles are part of data types in Choral, adding a new dimension to typing. For example, the statement `String@A a = "Hello from B"@B` would be ill-typed, because the expression on the right returns data at a different role from that expected by the left-hand side.

## From Choral to Java libraries

Given the class `HelloRoles`, the Choral compiler generates for each role a Java class with the behaviour for that role, in compliance with the source Choral class.

Assuming we saved the Choral program above in a file called `HelloWorlds.ch`, we can launch the Choral compiler with the command <kbd>choral epp HelloWorlds</kbd>.

We will obtain two Java classes: the Java class for role `A` is `HelloRoles_A` and the class for `B` is `HelloRoles_B`.

<div class="row">
<div class="col-lg-6 col-12">
```java
class HelloRoles_A {
	public static void sayHello() {
		String a = "Hello from A";
		System.out.println( a );
   }
}
```
</div>
<div class="col-lg-6 col-12">
```java
class HelloRoles_B {
	public static void sayHello() {
		String b = "Hello from B";
		System.out.println( b );  
   }
}
``` 
</div>
</div>

Each generated class contains only the instructions that pertain to that role. 

If Java developers want to implement the behaviour of method `sayHello` for a specific role of the `HelloRoles` choreography, say `A`, they just need to invoke the generated `sayHello` method in the respective generated class (`HelloRoles_A`).

<div class="border border-info bg-light px-5">
Using the `@` symbol in types comes from the tradition in [hybrid logic](https://en.wikipedia.org/wiki/Hybrid_logic), where `@` is used to express the "world" at which a statement is valid. Similarly, in Choral, `@` expresses the roles at which a data type lives.

You can still use the `@` symbol to write also common Java-like annotations in other places, like in Java.
</div>
