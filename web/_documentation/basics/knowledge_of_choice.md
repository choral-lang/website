---
layout: documentation
title: Knowledge of Choice
parent: Basics
ancestor: Documentation
url: basics/knowledge_of_choice
---

# Knowledge of Choice

Knowledge of choice is a hallmark challenge of choreographies: when a choreography chooses between two alternative behaviours, roles should coordinate to ensure that they agree on which behaviour should be implemented.

We exemplify the challenge with the following code, which implements the consumption of a stream of items from a producer `A` to a consumer `B`.

```choral
// wrong implementation
consumeItems( 
  DiDataChannel@( A, B )< Item > ch, 
  Iterator@A< Item > it, 
  Consumer@B< Item > consumer
) { 
  if ( it.hasNext() ){ 
    it.next() 
    >> ch::<Item>com 
    >> cons::accept;
    consumeItems( ch, it, consumer ); 
  } 
}
```

Method `consumeItems` takes a channel from `A` to `B`, an iterator over a collection of items at `A`, and a consumer function for items at `B`. Role `B` works reactively, where its consumer function is invoked whenever the stream of `A` produces an element: if the iterator can provide an item, it is transmitted from `A` to `B`, consumed at `B`, and the method recurs to consume the other items.

The reader familiar with choreographies should recognise that <span class="warning">this method implementation is wrong</span>, due to (missing) knowledge of choice: the information on whether the if-branch should be entered or not is known only by `A` (since it evaluates the condition), so `B` does not know whether it should receive, consume, and recur, or do nothing and terminate.

In Choral, we adopts the typically choreographic solution to this problem, which is equipping a "selection" primitive to communicate constants drawn from a dedicated set of "labels", so that 
the compiler has enough information to build code that can react to choices made by other roles.

To define selections, Choral uses a method-level annotation `@SelectionMethod`, which developers can apply only to methods that can transmit instances of enumerated types between roles (the compiler checks for this condition). For example, we can specify a directed channel for sending such enumerated values with the following `DiSelectChannel` interface.
 
```choral
interface DiSelectChannel@( A, B ){ 
  @SelectionMethod 
  < T@X extends Enum@X< T@X > > T@B select( T@A m ); 
}
```

Our compiler assumes that implementations of methods annotated with `@SelectionMethod` return at the receiver the same value given at the sender.

Typically, channels used in choreographies are assumed to support both data communications and selections. We can specify this with `DiChannel`s (directed channel), a subtype of both `DiDataChannel` and `DiSelectChannel`.

```choral
interface DiChannel@(A, B)< T@X > extends 
  DiDataChannel@( A, B )< T >, 
  DiSelectChannel@( A, B ) 
{}
```

Using `DiChannel`s, we can update `consumeItems` to respect the knowledge of choice.

```choral
consumeItems( 
  DiChannel@( A, B )< Item@X > ch, 
  Iterator@A< Item > it, 
  Consumer@B< Item > consumer ) { 
  if (it.hasNext()) {
    ch.< Choice >select( Choice@A.GO );
    it.next() >> ch::< Item >com >> consumer::accept; 
    consumeItems( ch, it, consumer ); 
  } else { 
    ch.< Choice >select( Choice@A.STOP ); 
  } 
}
```

<p class="text-center text-monospace">
Try it yourself: see the [source code](https://github.com/choral-lang/examples/tree/master/consume-items) on <i class="fab fa-github"></i>.
</p>

Differently from the previously broken implementation of `consumeItems`, now role `A` sends a selection of either `GO` or `STOP` to `B`. Role `B` can now inspect the received enumerated value to infer whether it should execute the code for the if- or the else-branch of the conditional. 

This information is exploited by our static analyser to check that `consumeItems` respects the knowledge of choice, and also by our compiler to generate code for B that reacts correctly to the choice performed by `A`.

The Choral compiler supports three features to make knowledge of choice flexible:

- its knowledge-of-choice check works with arbitrarily-nested conditionals. 
- knowledge of choice can be propagated transitively. Say that a role `A` makes a choice that determines that two other roles `B` and `C` should behave differently, and `A` informs `B` of the choice through a selection. Now either `A` or `B` can inform `C` with a selection because our compiler sees that `B` now possesses knowledge of choice;
- knowledge of choice is required only when necessary: if `A` makes a choice and another role, say `B`, does not need to know because it performs the same actions (e.g., receiving an integer from `A`) in both branches, then no selection is necessary.