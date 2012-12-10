# Refinery

A replacement for xls2yml which takes a source, creates a temporary Turbine
graph, and runs a series of transforms ("catalysts") adjusting the graph data
prior to exporting back to YAML for use in ETengine.

For the moment, the graph source is a manually-constructed "stub" graph which
is used for developing new features. Once the stub graph is reasonably complex
it will  be replaced by parsing the InputExcel CSVs. In the longer term, the
CSVs will likely also be replaced with something else.

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
