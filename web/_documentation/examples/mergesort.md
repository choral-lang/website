---
layout: documentation
title: Merge Sort
parent: Examples
ancestor: Documentation
url: examples/merge_sort
github_code: https://github.com/choral-lang/examples/tree/master/choral/mergesort
---

# Merge Sort

In this use case, we present a three-way concurrent implementation of [merge sort](https://en.wikipedia.org/wiki/Merge_sort), which exemplifies the design of parallel algorithms in Choral. 

Our implementation leverages role parameterisation such that participants collaboratively switch the roles that they play at runtime.
We represent the three concurrent parties as the roles `A`, `B`, and `C`. The idea is to follow the steps of standard merge sort, with `A` acting as
"master" and the other as slaves. Specifically, `A` divides the unsorted list into two sublists and then communicates them to `B` and `C`, respectively. We then recursively invoke merge sort on each sublist, but with switched roles: in one call, `B` becomes the master that uses `A` and `C` as slaves; in the other call, `C` is the master using `A` and `B` as slaves. `B` and `C` then return their sorted sublists to `A`, which can merge them as usual.

<div class="col-6 mx-auto" markdown=0>
<a target="_blank" href="/img/merge_sort.png"><img class="img-fluid" src="/img/merge_sort.png" alt=""></a>
</div>

The sequence diagram in the Figure above represents the execution of our choreography by three endpoint nodes for an input list [15, 3, 14]. We use numbered subscripts to denote the round that each interaction belongs to. Node1 starts by playing role A and holds the initial list, while the other two nodes initially play the slave roles. In the first round, Node1 asks Node2 and Node3 to sort the sublists obtained from the initial list. This starts a recursive call (second round) where Node2 is the master and the others are slaves that help it to sort its sublist. Node2 now splits its sublist into smaller lists and asks the other two nodes to sort them (sort2). When this round is completed, each node contains a sorted sublist, and we can get up the recursion stack to the nodes playing their original roles, where now A collects the results from the others (B and C coordinate to decide who communicates first).

The logic that we have just described is implemented by the following Mergesort class.

```choral
public class Mergesort@( A, B, C ){
  
  SymChannel@( A, B )< Object > ch_AB;
  SymChannel@( B, C )< Object > ch_BC;
  SymChannel@( C, A )< Object > ch_CA;
  
  public Mergesort( 
    SymChannel@( A, B )< Object > ch_AB,
    SymChannel@( B, C )< Object > ch_BC,
    SymChannel@( C, A )< Object > ch_CA 
  ) { 
    this.ch_AB = ch_AB;
    this.ch_BC = ch_BC;
    this.ch_CA = ch_CA; 
  }

  public List@A< Integer > sort( List@A< Integer > a ){ 
    if ( a.size()> 1@A ) {
      ch_AB.< Choice >select( Choice@A.L );
      ch_CA.< Choice >select( Choice@A.L );
      Mergesort@( B, C, A ) mb = new Mergesort@( B, C, A )( ch_BC, ch_CA, ch_AB );
      Mergesort@( C, A, B ) mc = new Mergesort@( C, A, B )( ch_CA, ch_AB, ch_BC );
      Double@A pivot = a.size() / 2@A 
        >> Math@A::floor
        >> Double@A::valueOf; 
      List@B<Integer> lhs = a.subList( 0@A, pivot.intValue() )
        >> ch_AB::< List< Integer > >com 
        >> mb::sort;
      List@C< Integer > rhs = a.subList( pivot.intValue(), a.size() )
        >> ch_CA::< List< Integer > >com 
        >> mc::sort; 
      return merge( lhs, rhs );
    } else {
      ch_AB.< Choice >select( Choice@A.R );
      ch_CA.< Choice >select( Choice@A.R );
      return a;
    } 
  }
  
  private List@A< Integer > merge ( List@B< Integer> lhs, List@C< Integer> rhs ) {
    if( lhs.size() > 0@B ) {
      select( MChoice@B.L, ch_AB ); select( MChoice@B.L, ch_BC );
      if( rhs.size() > 0@C ){
        select( MChoice@C.L, ch_CA ); select( MChoice@C.L, ch_BC );
        ArrayList@A< Integer > result = new ArrayList@A< Integer >();
        if( lhs.get( 0@B ) <= ch_BC.< Integer >com( rhs.get( 0@C ) ) ){
          select( MChoice@B.L, ch_AB ); select( MChoice@B.L, ch_BC );
          lhs.get( 0@B ) >> ch_AB::< Integer >com >> result::add;
          merge( lhs.subList( 1@B, lhs.size() ), rhs ) >> result::addAll;
          return result;
        } else {
          select( MChoice@B.R, ch_AB ); select( MChoice@B.R, ch_BC );
          rhs.get( 0@C ) >> ch_CA::< Integer >com >> result::add;
          merge( lhs, rhs.subList( 1@C, rhs.size() ) ) >> result::addAll;
          return result;
        }
      } else {
        select( MChoice@C.R, ch_CA ); select( MChoice@C.R, ch_BC );
        return lhs >> ch_AB::< List< Integer > >com;
      }
    } else {
      select( MChoice@B.R, ch_AB ); select( MChoice@B.R, ch_BC );
      return rhs >> ch_CA::< List< Integer > >com;
    }
  }
}
```

<p class="text-center text-monospace">
Try it yourself: see the [source code](https://github.com/choral-lang/examples/tree/master/choral/mergesort) on <i class="fab fa-github"></i>.
</p>

The sorting algorithm is implemented by the sort method, which uses the private merge method (omitted) to recursively handle the point-wise merging of ordered lists. For lists of size greater than 1, the algorithm creates two new `Mergesort` objects by instantiating roles such that they get switched as we discussed, splits the list at the master, communicates the resulting sublists to the slaves, recursively invokes merge sort with the switched roles, and finally merges the results.

The remaining code resembles (the choreography of) typical parallel merge sort implementations. A key benefit of Choral for parallel programming is that the compiled code is deadlock-free by construction, as usual for choreographic programming.