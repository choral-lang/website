---
layout: documentation
title: Distributed Authentication
parent: Examples
url: examples/distributed_authentication
github_code: https://github.com/choral-lang/examples/tree/master/choral/distributed-authentication
---

# Distributed Authentication

We write a choreography for distributed authentication inspired by [OpenID](https://openid.net/), where an `IP` ("Identity Provider") authenticates a `Client` that accesses a third-party `Service`. 

We start by introducing an auxiliary class, `AuthResult`, that we will use to store the result of
authentication. The idea is that, after performing the authentication protocol, both the Client and the Server should have an authentication token if the authentication succeeded, or an "empty" value if it failed. We model this by extending the [BiPair class](/documentation/basics/bipair.html).

```choral
public class AuthResult@( A, B ) extends 
  BiPair@( A, B )< Optional@A< AuthToken >, Optional@B< AuthToken > > { 
  
  public AuthResult( AuthToken@A t1, AuthToken@B t2 ){ 
    super( Optional@A.< AuthToken >of( t1 ), Optional@B.< AuthToken >of( t2 ) ); 
  } 
  
  public AuthResult(){ 
    super( Optional@A.< AuthToken >empty(), OptionalB.< AuthToken >empty() ); 
  }

}
```

The constructors of `AuthResult` guarantee that either both roles (`A` and `B`) have an optional containing a value or both optionals are empty (`Optional` is the standard Java type). Since `AuthResult` extends `BiPair`, these values are locally available by invoking the left and right methods. We now present the choreography for distributed authentication, as the `DistAuth` class below.

```choral
enum AuthBranch { OK, KO }

public class DistAuth@( Client, Service, IP ){
  
  private TLSChannel@( Client, IP )< Object > ch_Client_IP; 
  private TLSChannel@( Service, IP )< Object > ch_Service_IP; 
  
  public DistAuth( 
    TLSChannel@( Client, IP )< Object > ch_Client_IP,
    TLSChannel@( Service, IP )< Object > ch_Service_IP
  ) { 
    this.ch_Client_IP = ch_Client_IP; 
    this.ch_Service_IP = ch_Service_IP; 
  }

  private static String@Client calcHash( 
    String@Client salt, 
    String@Client pwd 
  ){ /*...*/ }
  
  public AuthResult@( Client, Service ) authenticate( Credentials@Client credentials ) { 
    String@Client salt = credentials.username
    >> ch_Client_IP::<String>com 
    >> ClientRegistry@IP::getSalt 
    >> ch_Client_IP::<String>com; 

    Boolean@IP valid = calcHash( salt, credentials.password )
    >> ch_Client_IP::<String>com 
    >> ClientRegistry@IP::check; 

    if ( valid ) {
      ch_Client_IP.< EnumBoolean >select( AuthBranch@IP.OK );
      ch_Service_IP.< EnumBoolean >select( AuthBranch@IP.OK );
      AuthToken@IP t = AuthToken@IP.create();
      return new AuthResult@( Client, Service )( 
        ch_Client_IP.<AuthToken>com( t ), 
        ch_Service_IP.<AuthToken>com( t )
      );
    } else {
      ch_Client_IP.< EnumBoolean >select( AuthBranch@IP.KO );
      ch_Service_IP.< EnumBoolean >select( AuthBranch@IP.KO );
      return new AuthResult@( Client, Service )();
    }
  }
}
```

<p class="text-center text-monospace">
Try it yourself: see the [source code](https://github.com/choral-lang/examples/tree/master/choral/distributed-authentication) on <i class="fab fa-github"></i>.
</p>

Class `DistAuth` is a multiparty protocol parameterised over three roles: `Client`, `Service`, and `IP` (for Identity Provider). 

It composes two channels as fields, which respectively connect `Client` to `IP` and `Service` to `IP`&mdash;hence, interaction between `Client` and `Service` can only happen if coordinated by `IP`. 

The channels are of type `TLSChannel`, a class for secure channels from the Choral standard library that uses TLS for security and the [Kryo library](https://github.com/EsotericSoftware/kryo) for marshalling and unmarshalling objects. 
Class `TLSChannel` implements interface `SymChannel` (as seen in the [Channel documentation](/documentation/basics/channels.html)) so it can be used in both directions. 

The private method `calcHash` (with the omitted body) implements the local code that `Client` uses to hash its password.

Method `authenticate` is the key piece of `DistAuth`, which implements the authentication protocol. 

It consists of three phases. In the first phase, the `Client` communicates its username to `IP`, which `IP` uses to retrieve the corresponding salt in its local database `ClientRegistry`; the salt is then sent back to `Client`. 
The second phase deals with the resolution of the authentication challenge. `Client` computes its hash with the received salt and its locally-stored password, and sends this to `IP`. `IP` then checks whether the received hash is valid, storing this information in its local variable valid. The result of the check is a `Boolean` stored in the valid variable located at `IP`. The first two phases codify some best practices for distributed authentication and password storage: the identity provider `IP` never sees the password of the client, but only its attempts at solving the challenge (the salt), which `Client` can produce with private information (here, its password). In the third phase, `IP` decides whether the authentication was successful or not by checking valid. In both cases `IP` informs the `Client` and the `Service` of its decision, using selections to distinguish between success (represented by `OK`) or failure (represented by `KO`). In the case of success, `IP` creates a new authentication token and communicates the token to both `Client` and `Service`. The protocol can now terminate and return a distributed pair (an `AuthResult`) that stores the same token at both `Client` and `Service`, which they can use later for further interactions. In case of failure, an authentication result with empty optionals is returned.

## Compilation

We now discuss key parts of the compilation of `DistAuth` for role `Client`, i.e., the Java library that clients can use to authenticate to an identity provider and access a service.

```java
public class DistAuth_Client {
  
  private TLSChannel_A< Object > ch_Client_IP;
  
  public DistAuth_Client( TLSChannel_A < Object > ch_Client_IP ){ 
    this.ch_Client_IP = ch_Client_IP; 
  }
  
  private String calcHash( String salt, String pwd ) { /*...*/ }

  public AuthResult_A authenticate( Credentials credentials ) {
    String salt = ch_Client_IP.< String >com( ch_Client_IP.< String >com( credentials.username ) );
    ch_Client_IP.< String >com( calcHash( salt, credentials.password ) );
    switch( ch_Client_IP.< AuthBranch >select( Unit.id ) ){ 
      case OK -> { 
        return new AuthResult_A( ch_Client_IP.< AuthToken >com( Unit.id ), Unit.id );
      } 
      case KO -> { 
        return new AuthResult_A();
      }
      default -> { 
        throw new RuntimeException( /*...*/ ); 
      }
    }
  }
}
```

The field, constructor, and static method are straightforward projections of the source class for role `Client`&mdash;fields and parameters pertaining only other roles disappeared. The interesting code is within the body of the `authenticate` method, which defines the local behaviour of `Client` in the authentication protocol. 
Note that forward chainings (`>>`) become plain nested calls in Java. 
In the method, the client sends its username to the identity provider and receives back the salt. Recalling [alien data types](/documentation/basics/interaction.html#alien-data-types), the innermost invocation of method `com` returns a `Unit`, since the client acts as sender here. Once the username is sent, the innermost `com` returns and we run the outermost invocation of `com`, which received the `salt` through the channel with the identity provider. Then, the client sends the computed hash to the identity provider.

The remaining lines of the method exemplify how the Choral compiler implements knowledge of choice for roles that need to react to decisions made by other roles. The client receives an enumerated value of type `AuthBranch`, which can be either `OK` or `KO`, through the channel with the identity provider. Then, a `switch` statement matches the received value to decide whether (case `OK`) we shall receive an authentication token from the identity provider and store it as an `AuthResult_A` or (case `KO`) authentication failed.