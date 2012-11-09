# Refinery

A replacement for xls2yml which takes an input source, creates a temporary
Turbine graph, and runs a series of "transforms" adjusting the graph data and
structure, prior to exporting back to YAML for use in ETengine.

For the moment, "input source" is InputExcel CSVs, but may in the future be 
something completely different.
