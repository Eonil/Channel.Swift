

**THIS PROJECT HAS BEEN ABANDONED AND REPLACED BY ANOTHER PROJECT**
**DO NOT USE THIS PROJECT**




Channel
=======
Hoon H.

`Channel` is essentially a data event processing framework.
Each node transfers data event signals to (registered) next 
nodes.





Getting Started
---------------







Fundamentals
------------

`Channel`s are categorized into two families of nodes.

-	State-less
-	State-ful

State-less nodes are designed for procedure call and event 
passing. This is most natural stuff that you would expect from
a signal processing network. Nothing will be stored in any
passage node. And you can perform various processings on the
signals such as filtering, mapping or etc..

State-less nodes are categorized into three core types.

-	Emitter
-	Relay
-	Monitor

As their name designates, they're responsible to (1) emit, (2) relay and
(3) monitor the signals.

State-ful nodes are designed to provide state repository. In
other words, an observeable data graph, or data binding.
There are 4 types of repositories in this category.

-	Value
-	Set
-	Array
-	Dictionary



Firing events on Registering/Deregistering
------------
By default, no Channel componnt fires something on registering/deregistering 
moment. Anyway some specialized component such as repository can fire 
initiation/termination events on registering/deregistering moments.








Collection Repository
---------------------

Each type of repository emits proper transaction signals that
can be used to reproduce exact state of the repository if the 
receiver performs correct procedures.

Of course, this replication is not useful without some extra
transforms. You also have some signal transformation nodes.









Asynchronous Signaling
----------------------

Some node can emit signals asynchronously.
Asynchronous signaling is provided by asynchronous gate that 
called `Wait`. This gate can connect two terminal synchronous 
gates. Buffered signaling is a kind of asynchronous signaling.

Unlike synchronous signaling, signal passing thread is undefined 
in asynchronous signaling node. 




Asymmeric Signaling
-------------------

Basically, single signal input produces single signal output in
synchronous node, but this doesn't have to be in asynchronous 
node. Single signal input may produce multiple output and vice-
versa.



Signal Buffering
----------------

This is designed for GUI front-end. Sometimes GUI front-end 
need to perform timely operation such as animation, and usually,
they cannot respond immediately to signals at the time. In this
case, you can use buffered storage to deliver signals later.
Furthermore, buffered signals can be more efficient by eliminating
duplicated states. 






Type Hierarchy
--------------

This tree describes what you can do on each node classes.
Subnodes provides all the features of supernodes.

-	`Gate`							Provides nothing.
									Actually gate equips all the needed functionalities to configure full 
									signaling network, but just does not expose them to provide static 
									validity check. Those functionalities will be exposed at subclasses.

	-	`Emitter`					A gate that allows you to send some signals to registered `Sensor`s.
									An emitter cannot be plugged into another node.

		-	`Repository`			An emitter that let you store a state.
									You can read stored state.
\									Your signal dispatch will mutate the state before to be sent to registered
									`Sensor`s.

		-	`Proxy`					An emitter that provides read-only view of a `Repository`.
									This node dispatches exactly same signals of the repository, so you can
									use this as a read-only interface of a repository.
									Proxies can be chained to another proxies.

	-	`Sensor`					A gate that can be plugged into another `Emitter`s or `Relay`s to 
									react on their signal dispatch.

		-	`Relay`					A sensor that re-dispatches received signals.

		-	`Monitor`				A sensor that calls a function for receiving signals.
							



Basically, you plug a `Sensor` to an `Emitter`.

	Emitter		>>>		Sensor
	
Some sensors are terminal.

	Emitter		>>>		Monitor

And others are non-terminal.

	Emitter		>>>		Relay		>>>		Monitor

Non-terminal sensors can be chained.

	Emitter		>>>		Relay		>>>		Relay		>>>		Relay		>>>		Monitor






















