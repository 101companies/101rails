class CachedGraph

  def initialize
    @data = Concurrent::Atom.new({
      graph: RDF::Graph.load(onto_path, format: :ttl),
      mtime: File.mtime(onto_path)
    })
  end

  private

  def method_missing(method_name, *arguments, &blck)
    if @data.value[:graph].respond_to?(method_name)
      if @data.value[:mtime] != File.mtime(onto_path)
        @data.swap do |_|
          {
            graph: RDF::Graph.load(onto_path, format: :ttl),
            mtime: File.mtime(onto_path)
          }
        end
      end
      @data.value[:graph].send(method_name, *arguments, &block)
    end
  end

  def onto_path
    @_onto_path ||= Rails.root.join('../101web/data/dumps/ontology.ttl')
  end

end
