module Refinery
  class Exporter
    # Public: Creates a new Exporter which takes a Turbine graph and creates
    # ETsource YAML.
    #
    # graph - The Turbine graph.
    #
    # Returns a new Exporter.
    def initialize(graph)
      @graph = graph
    end

    # Public: Writes the Turbine graph to ETsource YAML.
    #
    # Presently supports only writing to the main "topology.yml" file, and
    # does not include slots.
    #
    # dir - Path to the directory in which the YAML data is saved.
    def export(dir)
      File.write('topology.yml', YAML.dump(to_h))
    end

    # Internal: Converts the graph to a big hash suitable for saving as the
    # topology file.
    #
    # Returns a hash.
    def to_h
      @graph.nodes.each_with_object({}) do |node, data|
        data[node.key.to_s] = stringify_keys(
          node.properties.merge(links: links_for(node)))
      end
    end

    #######
    private
    #######

    # Internal: Given a node, returns it's YAML-formatted outward links.
    #
    # node - The node whose edges are to be formatted.
    #
    # Returns an array of strings.
    def links_for(node)
      node.out_edges.map do |edge|
        "#{ edge.from.key }-(#{ edge.label }) -- ? --> " \
        "(#{ edge.label })-#{ edge.to.key }"
      end.to_a
    end

    # Internal: Given a Hash, converts its keys to strings.
    #
    # hash - The hash whose keys are to be changed.
    #
    # Returns a hash.
    def stringify_keys(hash)
      hash.each_with_object({}) do |(key, value), stringified|
        stringified[key.to_s] = value
      end
    end
  end # Exporter
end # Refinery