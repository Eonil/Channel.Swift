



Channel
-------

`Channel` is essentially a data event processing framework.
Each node transfers data event signals to (registered) next 
nodes.

`Channel`s are categorized into two families of nodes.

-	State-less
-	State-ful

State-less nodes are designed for procedure call and event 
passing. This is most natual stuff that you would expect from
a signal processing framework. Nothing will be stored in any
passage nodes. And you can perform various processings on the
signals such as filtering, mapping or etc..

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

Each type of repository produces proper transaction signals to
reproduce exact state of the repository if the receiver performs
correct procedures.