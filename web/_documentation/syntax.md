---
layout: documentation
title: Syntax
url: syntax
---

# Coming soon

Choral incorporates a large subset of Java (extended to our role parameters for types), but some features are still missing. We plan on introducing them in future releases.

We are still working on writing this section of the documentation. In the meantime, you can check the syntax of Choral in section 4.1 ("Language") of our [article](https://arxiv.org/abs/2005.09520), especially Figure 5.

The following syntax is still not supported by Choral:
- lambda expressions (but functional interfaces are supported, so Choral libraries can be invoked by passing lambda expressions from Java);
- for and while loops (for now, we use recursion instead);
- static initialiser blocks;
- wildcards in generics;
- arrays (but collections are supported, like List, etc.).
