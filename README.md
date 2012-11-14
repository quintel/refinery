# Refinery

A replacement for xls2yml which takes a source, creates a temporary Turbine
graph, and runs a series of transforms ("catalysts") adjusting the graph data
prior to exporting back to YAML for use in ETengine.

For the moment, the graph source is a manually-constructed "stub" graph which
is used for developing new features. Once the stub graph is reasonably complex
it will  be replaced by parsing the InputExcel CSVs. In the longer term, the
CSVs will likely also be replaced with something else.
