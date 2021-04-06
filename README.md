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
