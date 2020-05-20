---
layout: home
---

 <div class="row">
  <div class="col-6 mr-auto ml-auto">
   <a href="/"><img class="img-fluid" src="/img/choral_logo.png"></a>
  </div>
  <div class="col-12" style="text-align: center;">
  <p style="font-variant: small-caps;">
   a choreographic programming language
   </p>
   <a href="/downloads.html"><button type="button" class="btn btn-primary">Install</button></a>
   <a href="/documentation.html"><button type="button" class="btn btn-info">Learn</button></a>
   <a href="/index.html#presentation-paper"><button type="button" class="btn btn-success">Read the Paper</button></a>
  </div>
 </div>


## Syntax

The syntax of Choral is inspired by one of the most widely-used mainstream
languages: Java. Thus, Java developers (and akin, like C++/#) benefit from a
graceful learning curve to grasp the main concepts of the Choral language.

```choral
class MyExample@( Server, Client, Logger ) {
 
 Channel< String >@( Server, Logger ) logChannel;
 Log@Logger log;

 MyExample( Channel< String >@( Server, Logger ) logChannel, Log@Logger log ){
    this.logChannel = logChannel;
    this.log = log;
 }

 void sendMessage( Channel@( Server, Client ) channel ) {
  String@Server message = channel.com( Panel@Client.prompt( "Insert the message for the server" ) );
  log.record( logChannel.com( message ) );
  System@Server.out.println( "Client sent: "@Server + message );
 }
```
---

## Development Process 

Phasellus eget sagittis est. Suspendisse vestibulum lectus in ligula ultricies
rhoncus. Cras eget vehicula justo, non aliquam risus. Curabitur vitae lorem sit
amet neque hendrerit tristique. Mauris eu finibus nulla, id fermentum nisi. Nunc
fermentum, mauris eget facilisis tincidunt, urna purus blandit nibh, non
vulputate velit velit eu ante. Pellentesque volutpat lectus leo, vitae venenatis
ipsum euismod id. Mauris in accumsan lacus. Sed fringilla elementum velit, eu
ultrices quam aliquam vitae. Pellentesque habitant morbi tristique senectus et
netus et malesuada fames ac turpis egestas.

<div class="row">
<div class="col-12">
<img class="img-fluid" src="/img/development_process.png" alt="">
</div>
</div>

---

## Type System

Cras lobortis consequat tincidunt. Vestibulum ante ipsum primis in faucibus orci
luctus et ultrices posuere cubilia curae; Quisque sed tortor gravida, blandit
elit et, ultrices nulla. Praesent ultrices accumsan ipsum, at mattis arcu
tincidunt rhoncus. Vestibulum eleifend, lectus sit amet porta maximus, nibh
augue varius nisl, non venenatis massa mauris sit amet mauris. Quisque placerat
elit vel ipsum tincidunt fermentum. Quisque venenatis finibus est, vitae
placerat tellus facilisis eget.

```choral
class Wrong@( Wrong, Wrong, Wrong1 ) {
 
 Channel< Wrong >@( Wrong, Wrong ) logChannel;
 Wrong@Wrong wrong;

 Wrong( Channel< Wrong >@( Wrong, Wrong1 ) logChannel, Wrong@Wrong wrong ){
    this.logChannel = logChannel;
    this.wrong = wrong;
 }

 void wrong( Channel@( Wrong, Wrong1 ) channel ) {
  Wrong@Wrong1 message = channel.com();
 }
}
```

---

## Seamless integration with existing Java code

Donec in diam posuere, porttitor neque in, vehicula felis. Vivamus sagittis
sapien et neque lacinia lobortis. Mauris ligula magna, consectetur eget luctus
pharetra, bibendum sed enim. Integer pharetra turpis ac arcu aliquam, nec
pretium nibh porttitor. Vestibulum ante ipsum primis in faucibus orci luctus et
ultrices posuere cubilia curae; Donec dapibus ut mi sit amet interdum. Nunc eu
tristique ante. Etiam scelerisque augue at pharetra tempus. Pellentesque rhoncus
luctus odio, eget luctus nisi imperdiet in. Aenean imperdiet ac eros id varius.
Maecenas orci sem, rhoncus a venenatis vitae, consectetur sit amet massa. Ut
aliquet ex sed rutrum blandit.

---

<div class="row">
<div class="col-7">
## Presentation Paper
For an in-depth presentation of Choral, please refer to the paper 
**[Choreographies as Object](https://arxiv.org/abs/2005.09520)**. 

The paper presents the Choral framework for programming choreographies 
(multiparty protocols). The framework builds on top of mainstream programming 
abstractions: in Choral, choreographies are objects. Given a choreography 
that defines interactions among some roles (Alice, Bob, etc.), an 
implementation for each role in the choreography is automatically generated 
by a compiler. These implementations are libraries in pure Java, which 
developers can modularly compose in their own programs to participate 
correctly in choreographies.
</div>
<div class="col-5">
<a href="https://arxiv.org/abs/2005.09520">
<img class="img-thumbnail" src="/img/paper.png" alt="">
</a>
</div>
<div class="col-12">
If you want to cite this work, please use the entry below.
```
@misc{GMP2020,
   title={Choreographies as Objects},
   author={Saverio Giallorenzo and Fabrizio Montesi and Marco Peressotti},
   year={2020},
   eprint={2005.09520},
   archivePrefix={arXiv},
   primaryClass={cs.PL}
}
```
</div>
</div>
