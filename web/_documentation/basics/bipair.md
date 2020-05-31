---
layout: documentation
parent: Basics
ancestor: Documentation
title: BiPair
---

# Distributed data structures

## BiPair

Fields of Choral classes can be distributed over different roles.
For example, a class `BiPair` can define a "distributed pair" storing two values at different roles.

```choral
class BiPair@(A, B)<L@X, R@Y> {
  private L@A left; 
  private R@B right;
  public BiPair(L@A left, R@B right) { 
    this.left = left; 
    this.right = right; 
  } 
  public L@A left() { 
    return this.left; 
  }
  public R@B right() { 
    return this.right; 
  } 
}
```

Class `BiPair` is distributed between roles `A` and `B` and has two fields, `left` and `right`.
The class is also parameterised on two data types, `L` and `R`, which exemplifies our support for [generics](https://en.wikipedia.org/wiki/Generics_in_Java). 
In the class declaration, `L@X` specifies that `L` is expected to be a data type parameterised over a single role, abstracted by `X`; similarly for `R@Y`. 
Choral interprets type parameter declarations and usages as in Java generics: the first appearance of a type parameter declares the parameter (it is a "binder"), while subsequent occurrences of the same parameter name are usages of that parameter (these occurrences are "bound").

The two fields found in the first two lines after the class declaration, `left` and `right`, are respectively located at `A` and `B` with types `L` and `R`. 
Choral classes can have constructors that take data in from different roles, as shown by the method `public BiPair(L@A left, R@B right)`.
The `BiPair` class also has two accessor methods that return data at different roles, to access the respective two fields `left` and `right`.

Data structures like `BiPair` are useful when defining choreographies where the data at some role needs to correlate with data at another role, as with distributed authentication tokens. We are going to use this in our examples later on.

## Instantiating roles

The roles `A` and `B` mentioned in `class BiPair` are actually _parameters_ that can be replaced at will when objects of the class are created: Choral class types are type constructors, or higher-kinded types, parameterised over roles.

For example, we can now freely create a `BiPair` for roles `Client` and `Server`, and another `BiPair` for other roles `Alice` and `Bob`.

```choral
BiPair@(Client, Server)<Integer, Integer> p1 = new BiPair@(Client, Server)<Integer, Integer>(10@Client, 20@Server);
BiPair@(Alice, Bob)<String, String> p2 = new BiPair@(Alice, Bob)<Integer, Integer>("Key"@Alice, "Value"@Bob);

p.left(); // this returns 10@Client
p2.right(); // this returns "Value"@Bob
```

We do not have a lot of type inference in Choral yet. For example, the first line of the snippet above could be written as follows in principle.

```choral
var p1 = new BiPair@(Client, Server)<>(10, 20); // not supported.. yet!
```

Having to write types explicitly helped us in checking that Choral makes sense while we developed our first examples. We plan on introducing type inference in the future.