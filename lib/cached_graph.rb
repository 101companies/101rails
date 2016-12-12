class CachedGraph

  def initialize
    @graph = RDF::Graph.load(onto_path, format: :ttl)
    @mtime = File.mtime(onto_path)
    @lock = Concurrent::ReadWriteLock.new

    @update_task = Concurrent::TimerTask.new(timeout_interval: 60, run_now: true) do
      if @mtime != File.mtime(onto_path)
        @lock.with_write_lock do
          @graph = RDF::Graph.load(onto_path, format: :ttl)
          @mtime = File.mtime(onto_path)
        end
      end
    end
    @update_task.execute
  end

  def with_lock(&block)
    @lock.with_read_lock do
      yield
    end
  end

  private

  def method_missing(method_name, *arguments, &blck)
    if @graph.respond_to?(method_name)
      @lock.with_read_lock do
        @graph.send(method_name, *arguments, &block)
      end
    end
  end

  def onto_path
    @_onto_path ||= Rails.root.join('../101web/data/dumps/ontology.ttl')
  end

end
