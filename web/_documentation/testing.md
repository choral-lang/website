---
layout: documentation
title: Testing
url: testing
---

# ChoralUnit

Testing implementations of choreographies is hard, since the distributed programs of all participants need to be integrated (integration testing). 

This is why we equipped Choral with a first-party library called ChoralUnit: a testing tool that enables the writing of *integration tests as simple unit tests* for choreographic classes.

Following standard practice in object-oriented languages and inspired by [JUnit](https://en.wikipedia.org/wiki/JUnit), tests in ChoralUnit are defined as methods marked with a `@Test` annotation.

For example, we can define the following unit test for the [VitalsStreaming class](/documentation/examples/healthcare-service.html)

```choral
import choral.choralUnit.annotations.Test;

public class VitalsStreamingTest@(Device, Gatherer) {
 
 @Test
 public static void test1(){
  SymChannel@( Device, Gatherer )<Object> ch = TestUtils@( Device, Gatherer )
   .newLocalChannel( "VST_channel1"@[ Device, Gatherer ] );
  new VitalsStreaming@( Device, Gatherer )( ch, new FakeSensor@Device() )
   .gather(new PseudoChecker@Gatherer()); 
  } 

 }
 
 class PseudoChecker@R implements Consumer@R<Vitals> {

  public void accept( Vitals@R vitals ){
   Assert@R.assertTrue( "bad pseudonymisation"@R, isPseudonymised( vitals ) ); 
  }
  
  private static Boolean isPseudonymised( Vitals vitals ) { /* ... */ } 
 
 }
 
 class FakeSensor@R implements Sensor@R { /* ... */ }
```

Above, the test method `test1` checks that data is pseudonymised correctly by `VitalsStreaming`. 

Test methods must be annotated with `@Test`, be static, have no parameters, and return no values.

In test1, first we create a channel between the `Device` and the `Gatherer` by invoking the
`TestUtils.newLocalChannel` method, which is provided by ChoralUnit as a library to simplify
the creation of channels for testing purposes. This method returns an in-memory channel, which
both `Device` and `Gatherer` will find by looking it up in a shared map under the key `"VST_channel1"`. Thus, it is important that both roles will have the same key in their compiled code, which is guaranteed here by the fact that the expression `"VST_channel1"@[Device,Gatherer]` is actually syntax sugar for `"VST_channel1"@Device, "VST_channel1"@Gatherer`.

After the creation of the channel, we create an instance of `VitalsStreaming` (the choreography we want to test). 

We use a `FakeSensor` object to simulate a sensor that sends some data containing sensitive information (omitted). We then invoke the gather method, passing an implementation of a consumer that checks whether the data received by the `Gatherer` has been pseudonymised correctly.

Given a class like `VitalsStreamingTest`, the user compiles it by invoking our compiler
with a special flag (`--annotate`). This makes the compiler annotate each generated Java class with a `@Choreography` annotation that contains the name of its source Choral class and the role that the Java class implements. Once the compilation is finished, the ChoralUnit tool can be invoked to run the tests in the VitalsStreamingTest class, with the command 

<kbd>java -cp /path/to/the/projected/classes -jar ChoralUnit.jar VitalsStreamingTest</kbd>

Issuing that command, ChoralUnit will follow three steps: 

1. it finds all Java classes annotated with a @Choreography annotation whose name value corresponds to VitalsStreamingTest
2. Each discovered class has a method with the same name for each method in the source Choral test class (`test1` in our example). For each such method that is annotated with `@Test`, ChoralUnit starts a thread running the local implementation of the method by each class generated from the Choral source. 
3. The previous step is repeated for all test methods.

In our example, `VitalsStreamingTest` is compiled to a class for `Device` and another for
`Gatherer`, each with a `test1` method. Thus, ChoralUnit starts two threads, one running `test1` of the first generated Java class and the other running `test1` of the second generated Java class.