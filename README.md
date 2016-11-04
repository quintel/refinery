<h1 align="center">Refinery</h1>
<p align="center">Network solver for energy graphs.</p>

<p align="center">
  <a href="https://travis-ci.org/quintel/refinery"><img alt="Master branch build status" src="https://img.shields.io/travis/quintel/refinery/master.svg" /></a>

  <a href="https://codecov.io/gh/quintel/refinery"><img alt="Code coverage status" src="https://img.shields.io/codecov/c/github/quintel/refinery/master.svg" /></a>
</p>

Refinery is an energy-graph solver which, given demands on some nodes and
shares on some edges, seeks to find the demand of all the unspecified nodes.

Refinery is used at Quintel to take the the graph defined in
[ETSource][etsource], and determine the way in which energy flows through a
country; from the primary sources (such as coal production, or "ambient wind"),
all the way to the use in business, industry, and residences.

#### Terminology

* **Child** and **parent** nodes: Nodes which are connected to each other with
  an edge. The edge is "outbound" on the parent node, and "inbound" on the
  child. Nodes which are joined by an edge are considered **adjacent**.

  ![](https://dl.dropbox.com/sh/dr9ui09l5s2kgrt/8EMlQNebWz/parent-child.png)

* **Descendants** and **ancestors**: These terms are similar to "child" and
  "parent" but recurse edges infinitely in the respective direction. For
  example, "descendants" includes the children of the current node, all of
  it's children and so on.

  ![](https://dl.dropbox.com/sh/dr9ui09l5s2kgrt/n6gWN6GZJ0/ancestor-descendant.png)

* **Spouse**: Describes an arrangement of nodes which are connected to a
  common child:

  ![](https://dl.dropbox.com/sh/dr9ui09l5s2kgrt/hQIRCq0V0z/spouse.png)

* **Siblings**: Describes nodes which are connected to a common parent.

  ![](https://dl.dropbox.com/sh/dr9ui09l5s2kgrt/SEYBOLGAMz/sibling.png)

[etsource]: https://github.com/quintel/etsource
[atlas]:    https://github.com/quintel/atlas
