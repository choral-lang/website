---
layout: documentation
title: Channels
parent: Basics
ancestor: Documentation
url: basics/channels
---


# Channels

Choral types give us a new way to specify requirements on channels that prior work implicitly assumed, leading to the definition of a family of channel interfaces diagrammed below.

<div markdown=0>
<a target="_blank" href="/img/channels.jpg"><img class="img-fluid" src="/img/channels.jpg" alt=""></a>
</div>

From the left-most column, at the top, we find `DiDataChannel`, representing a directed channel parameterised over `T` (the type of the data that can be sent). We obtain `BiDataChannel`, a bidirectional data channel, by extending `DiDataChannel` once for each direction: 1 it binds the role parameters of one extension in the same order given for the role parameters of `BiDataChannel`, giving us a direction from `A` to `B` and 2 it binds the role parameters of the other extension in the opposite way, giving us a direction from `B` to `A`. 

The result is that `BiDataChannel` defines two `com` methods: one transmitting from `A` to `B`, the other from `B` to `A`. 

The last lines in 1 and 2 in the Figure complete the picture: the first generic data type `T` binds data from `A` to `B`, second generic data type `R` binds data from `B` to `A`. The `SymDataChannel` in the Figure, by extending the `BiDataChannel` interface and binding the two generic data types `T` and `R` with its only generic data type `T`, defines a bidirectional data channel that transmits one type of data, regardless its direction.

The right-most vertical hierarchy in the Figure represents channels supporting selections and it follows a structure similar to that of data channels. A `DiSelectChannel` is a directed selection channel and a `SymSelectChannel` is the bidirectional version&mdash;there is no `BiSelectChannel` since both directions exchange the same enumerated types.

The vertical hierarchy in the middle column of the Figure is the combination of the left-most and right-most columns. Interface `DiChannel` is a directed channel that supports both generic data communications and selections. `BiChannel` is its bidirectional extension (3 and 4 in the Figure), and `SymChannel` is the symmetric extension of `BiChannel`.