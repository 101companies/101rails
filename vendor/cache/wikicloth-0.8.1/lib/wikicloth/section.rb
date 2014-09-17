module WikiCloth

  class Section < String

    def initialize(title=nil, id=nil)
      self.title = title
      @children = []
      @id = id
      @template = nil
      @auto_toc = nil
    end

    def children
      @children
    end

    def id
      @id
    end

    def auto_toc=(val)
      @auto_toc = val
    end

    def template=(val)
      @template = val
    end

    def title=(val)
      if val =~ /^([=]{1,6})\s*(.*?)\s*(\1)/
        @depth = $1.length
        @clean_title = $2
        @title = val
      else
        @depth = 1
        @clean_title = val
        @title = val
      end
    end

    def title
      @clean_title
    end

    def depth
      @depth ||= 1
    end

    def get_section(id)
      return self.wikitext() if self.id == id
      @children.each do |child|
        ret = child.get_section(id)
        return ret unless ret.nil?
      end
      nil
    end

    def wikitext(opt={})
      options = { :replace => {} }.merge(opt)

      if options[:replace][self.id].nil?
        ret = "#{@title}#{self}"
        ret += @children.collect { |c| c.wikitext(options) }.join
        ret
      else
        options[:replace][self.id]
      end
    end

    def render(opt={})
      options = { :noedit => opt[:link_handler].nil? ? true : false }.merge(opt)
      if self.title.nil?
        ret = ""
      else
        ret = "\n#{@title}\n"
      end
      ret += self
      ret += "__TOC__" if @auto_toc
      ret += @children.collect { |c| c.render(options) } .join
      ret
    end

  end

end
