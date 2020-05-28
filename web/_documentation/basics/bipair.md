---
layout: documentation
parent: Basics
ancestor: Documentation
title: BiPair
---

# BiPair

As seen in the [Hello Roles](/documentation/basics/hello_roles.html) tutorial, fields of Choral classes carry state and can be distributed over different roles. 

For example, a class `BiPair` can define a "distributed pair" storing two values at different roles.

```choral
class BiPair@(A, B)<L@X, R@Y> {
  private L@A left; 
  private R@B right;
  public BiPair( L@A left, R@B right ) { 
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
Choral interprets binders as in Java generics: the first appearance of a parameter is a binder, while subsequent appearances of the same parameter are bound. 

The two field found at the first two lines after the class declaration, `left` and `right`, are respectively located at `A` and `B` with types `L` and `R`. 
Choral classes have constructors, as shown by the method `public BiPair( L@A left, R@B right )`.
The `BiPair` class also has two accessor method, to access the corresponding two fields `left` and `right`.

Data structures like BiPair are useful when defining choreographies where the data at some role needs to correlate with data at another role, as with distributed authentication tokens.