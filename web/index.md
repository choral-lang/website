---
layout: home
title: Home
---

 <div class="row">
  <div class="col-6 col-sm-4 mr-auto ml-auto text-center">
   <a href="/"><img class="img-fluid" src="/img/choral_logo.png"></a>
  </div>
  <div class="col-12 text-center">
  <p style="font-variant: small-caps;">
   a choreographic programming language
   </p>
   <a href="/install.html"><button type="button" class="btn btn-primary">Install</button></a>
   <a href="/documentation.html"><button type="button" class="btn btn-info">Learn</button></a>
   <a href="/index.html#article"><button type="button" class="btn btn-success">Read the article</button></a>
   <a href="https://github.com/choral-lang/choral"><button type="button" class="btn btn-secondary">View the source on <i class="fab fa-github"></i></button></a>
  </div>
 </div>

<!-- ## What -->

Choral is a language for the programming of _choreographies_.
A choreography is a multiparty protocol that defines how some _roles_ (the proverbial Alice, Bob, etc.) should coordinate with each other to do something together.

You can use Choral to program distributed authentication protocols, cryptographic protocols, business processes, parallel algorithms, or any other protocol for concurrent and distributed systems.
At the press of a button, the Choral compiler translates a choreography into a library for each role.
Developers can now use your libraries to make sure that their programs (like a client, or a service) follow your choreography correctly&mdash;see [Choral's methodology](#development-methodology-or-what-choral-does). Choral makes sure that your libraries are _compliant_ implementations of your choreography, makes you more productive, and prevents you from writing incompatible implementations of communications&mdash;see [Choral's advantages](#what-advantages-does-choral-bring).

Choral is a prototype: it is developed as part of an ongoing research project (see the [about page](/about.html)), and future releases might break backwards compatibility. It is already usable for early adoption and teaching.
If you're curious, you can [try it out yourself](/install.html) and [get in touch with us](/about.html#contacts)!

Choral is currently interoperable with Java, but we plan on extending it to support also other programming languages in the future.

## Language

If you just want to glance at how a Choral program looks like, you can jump to [Alice, Bob, and Carol go to a meeting](#alice-bob-and-carol-go-to-a-meeting) and then come back here for the details.

Choral is an object-oriented language with a twist: Choral objects have types of the form `T@(R1, ..., Rn)`, where `T` is the
interface of the object (as usual), and `R1, ..., Rn` are the roles that _collaboratively implement the object_. (Technically, Choral data types are higher-kinded types parameterised on roles, which generalise ideas previosly developed for choreographies and multitier programming; more on that at [the end of this page](#article).)

Incorporating roles in data types makes distribution manifest at the type level. For example, we can write a simple program that prints hello messages in parallel at two roles `Alice` and `Bob`.

```choral
class Hellos@(Alice, Bob) {	// A class of objects distributed over two roles, called Alice and Bob
	public static void main() {
		System@Alice.out("Hello from Alice"@Alice);	// Print "Hello from Alice" at Alice
		System@Bob.out("Hello from Bob"@Bob);		// Print "Hello from Bob" at Bob
	}
}
```

Class `Hellos` is not very interesting, because `Alice` and `Bob` do not interact.
Interaction is achieved by invoking methods that can "move" data from one role to another, like the `com` method of interface `SymChannel`.
We give a simplified view of this interface below&mdash;see the details in the documentation of [channels](/basics/channels.html).

```choral
// A bidirectional communication channel between two roles A and B
interface SymChannel@(A, B) {
	public void <T> T@B com(T@A mesg);	// given data of type T at A, returns data of type T at B
	/* more methods, not shown here... */
}
```

Choral _does not fix any middleware_: as long as you can satisfy the types of the choreography that you are writing, you can use your own implementations of communications and existing Java code in Choral. The Choral type system forces you to specify the communication requirements of your choreographies explicitly (channel topology, type of transmissible data, etc.).

Using channels, we can write more interesting choreographies, as we can see in the next example.

### Alice, Bob, and Carol go to a meeting

Alice calls Bob to ask if they could have a meeting with Carol on some `topic`.
Bob wants to know whether Carol could go first, so he asks her. If she can go, then he considers it himself. In the end, Alice needs to know the final result on whether the meeting can take place from Bob.

We can define this protocol as the class below. Note that Choral borrows the forward chaining operator `>>` from F#: in the following, `expression >> object::method` means `object.method(expression)`.


```choral
class MeetingVote@(Alice, Bob, Carol) {
	public static Boolean@Alice run(
		SymChannel@(Alice, Bob)<Object> chAB,		// A bidirectional channel between Alice and Bob that can transfer objects
		SymChannel@(Bob, Carol)<Object> chBC,		// A bidirectional channel between Bob and Carol that can transfer objects
		String@Alice topic,				// Alice's topic for the meeting
		Predicate@Bob<String> bobsPredicate,		// Bob's predicate to decide whether he could go
		Predicate@Carol<String> carolsPredicate		// Carol's predicate to decide whether she could go
	) {
		String@Bob x = topic >> chAB<String>::com;	// Alice's topic is communicated to Bob
		Boolean@Bob carolsChoice =
			x					// Bob's copy of the topic..
			>> chBC<String>::com			// ..is communicated to Carol.
			>> carolsPredicate::test		// Then Carol decides whether she wants to go..
			>> chBC<Boolean>::com;			// ..and communicates it to Bob.

		// Now Bob considers going only if Carol goes, and communicates the decision to Alice.
		return (carolsChoice && bobsPredicate.test(x)) >> chAB<Boolean>::com;
	}
}
```

---

## Development Methodology (or: what Choral does)

<div markdown=0>
<div class="text-center mx-auto col-6 col-md-5">
	<img class="img-fluid" src="/img/methodology.png" alt="">
</div>
<div class="text-center" style="font-variant: small-caps;">
Choral's development methodology
</div>
</div>

Choral is designed to generate correct implementations of choreographies as Java libraries. In Choral's development methodology (figure above):
- the intended coordination that a system should follow is written as a Choral choreography;
- then, the Choral compiler generates a Java library for each role defined in the choreography;
- finally, programmers can use these libraries in their own local implementations of each system participant (a service, a client, an actor, etc.).

For example, given a choreography like the one above for the roles `Alice`, `Bob`, and `Carol`, the Choral compiler generates a Java library for each role.
Each library offers an API that the programmer can use inside of their own project to participate in the choreography correctly within a concurrent/distributed system.

Let's have a look at the code that would be generated for Alice's Java library.

```java
class MeetingVote_Alice {
	public static Boolean run(
		SymChannel_A<Object> chAB,	// Alice's end of her channel with Bob
		String topic			// Alice's topic for the meeting
	) {
		chAB<String>.com(topic);	// Alice sends her topic to Bob
		return chAB<Boolean>::com;	// return what is received from Bob
	}
}
```

Notice that all code that has nothing to do with Alice from the choreography has disappeared. In other words, Alice does only what pertains her.

A Java developer can now import `MeetingVote_Alice` and invoke method `run` to coordinate correctly with third-party implementations of Bob and Carol.

This was a simple example.
Wanna see something more realistic? Jump to our [documentation](/documentation.html).

---

## What advantages does Choral bring?

- Choral saves you time. In our first use cases, Choral reduced the lines of code that we had to write to implement choreographies from 50% up to almost 400%.
- Choral makes your coordination code safer.
  * Its compiler takes care of implementing the local behaviour of each participant for you. Implementing correct local behaviour manually is hard.
  * It prevents entire classes of errors in the implementation of a choreography, like distributed programs performing incompatible communication actions and wrong pre-/post-processing of data. Furthermore, code generated by Choral is guaranteed not to introduce deadlocks (deadlock-freedom).
  * It gives you a global view on how roles coordinate with each other, so spotting inconsistencies is easier.
- You retain control of your library APIs: the method signatures of the compiled Java libraries are homomorphic to (they resemble the structure of) those in the source choreography. Essentially, what you see is what you get.

We think that Choral has the potential to be especially relevant for business processes, microservices, security protocols, and distributed services in general.

---

<div class="row">
<div class="col-12 col-md-8 col-lg-9 col-xl-10">
## Article

If you're interested in programming languages, want to know more about how Choral works and how it relates to other works, please refer to the article **[Choreographies as Object](https://arxiv.org/abs/2005.09520)**.
Choral has been influenced by previous work on [choreographic programming](https://www.fabriziomontesi.com/files/choreographic_programming.pdf) and the theoretical models that inspired multitier programming, like [hybrid logic](https://en.wikipedia.org/wiki/Hybrid_logic) and [Lambda 5](https://doi.org/10.1109/LICS.2004.1319623).
</div>

<div class="col-4 col-md-4 col-lg-3 col-xl-2 mx-auto">
<a href="https://arxiv.org/abs/2005.09520">
<img class="img-thumbnail" src="/img/paper.png" alt="">
</a>
</div>
</div>
