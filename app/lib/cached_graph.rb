class CachedGraph
  def initialize
    if File.exist?(onto_path)
      @graph = RDF::Repository.load(onto_path, format: :ttl)
      @mtime = File.mtime(onto_path)
    end

    @lock = Concurrent::ReadWriteLock.new

    @update_task = Concurrent::TimerTask.new(timeout_interval: 60, run_now: true) do
      if @mtime != File.mtime(onto_path)
        @lock.with_write_lock do
          @graph = RDF::Repository.load(onto_path, format: :ttl)
          @mtime = File.mtime(onto_path)
        end
      end
    end
    @update_task.execute
  end

  def with_lock
    @lock.with_read_lock(&block)
  end

  def has_graph?
    !@graph.nil?
  end

  private

  def method_missing(method_name, *arguments, &block)
    if @graph.respond_to?(method_name)
      @lock.with_read_lock do
        @graph.public_send(method_name, *arguments, &block)
      end
    end
  end

  def onto_path
    @_onto_path ||= if Rails.env.test?
                      Rails.root.join('spec/support/test_ontology.ttl')
                    else
                      File.expand_path('~/101web/data/dumps/ontology.ttl')
                    end
  end
end
