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
passing. This is most natual stuff that you would expect from
a signal processing framework. Nothing will be stored in any
passage nodes. And you can perform various processings on the
signals such as filtering, mapping or etc..

State-less noes are categorized into three core types.

-	Emitter
-	Relay
-	Monitor

As their name designates, they're responsible to (1) emitting, (2) relaying and
(3) monitoring the signals.


State-ful nodes are designed to provide state repository. In
other words, an observeable data graph, or data binding.
There are 4 types of repositories in this category.

-	Value
-	Set
-	Array
-	Dictionary









Collection Repository
---------------------

Collection repositories accept transaction signals, and apply
it to its collection, and transfers the signal to next nodes.

Each type of repository produces proper transaction signals that
can be used to reproduce exact state of the repository if the 
receiver performs correct procedures.






Signal Buffering
----------------

This is designed for GUI front-end. Sometimes GUI front-end 
need to perform timely operation such as animation, and usually,
they cannot respond immediately to signals at the time. In this
case, you can use buffered storage to deliver signals later.
Furthermore, buffered signals can be more efficient by eliminating
duplicated value.