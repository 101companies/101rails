class ValidatePage
  include SolidUseCase
  steps :validate

  SCHEMA_PREDICATES = [
    'hasMandatory',
    'hasOptional'
  ]

  def validate(params)
    page = params[:page]

    if page.present? && !page.instance_of?(WikiAtTimes)
      full_title = "Namespace:#{page.namespace}"
      errors = []
      warnings = []

      full_title = PageModule.unescape_wiki_url(full_title).strip
      nt = PageModule.retrieve_namespace_and_title(full_title)

      schema_triples = Triple
        .joins(:page)
        .where(pages: {namespace: nt['namespace'], title: nt['title']})
        .where(triples: {predicate: SCHEMA_PREDICATES})

      section_names = page.section_names
      triple_predicates = page.triples.map(&:predicate)

      section_errors, section_warnings = validate_sections(schema_triples, triple_predicates, section_names)
      errors = errors + section_errors
      warnings = warnings + section_warnings

      triple_errors, _ = validate_triple_ranges(page)
      errors = errors + triple_errors

      # missing links
      normalized_links = page.used_links
        .select do |link|
          !link.include?('::')
        end
        .map do |link|
        full_title = PageModule.unescape_wiki_url(link).strip
        nt = PageModule.retrieve_namespace_and_title(full_title)
        full_title = "#{nt['namespace'] || 'Concept'}:#{nt['title']}"
      end.uniq

      query_links = normalized_links.map do |full_title|
        underscore_title = full_title.gsub(' ', '_')
        [full_title, underscore_title]
      end.flatten.uniq

      found_linked_pages = Page.where("namespace || ':' || title in (?)", query_links)
        .pluck(:namespace, :title)
        .map { |a| a.join(':')  }

      missing = normalized_links - found_linked_pages

      missing.each do |link|
        errors << "Linked page #{link} is missing"
      end

      params[:errors] = errors
      params[:warnings] = warnings
    else
      params[:errors] = []
      params[:warnings] = []
    end

    continue(params)
  end

  private

  def validate_triple_ranges(page)
    errors = []
    triples = page.triples
    property_pages = Page
      .select(:id, :title)
      .includes(:triples)
      .where(namespace: 'Property', title: page.triples.pluck(:predicate))

    domains = Hash.new([])
    property_pages.each do |property_page|
      property_page.triples.each do |triple|
        if triple.predicate == 'hasDomain'
          domains[property_page.title] = domains[property_page.title] + [triple.object.split(':')[1]]
        end
      end
    end

    ranges = Hash.new([])
    property_pages.each do |property_page|
      property_page.triples.each do |triple|
        if triple.predicate == 'hasRange'
          namespace = PageModule.retrieve_namespace_and_title(triple.object)['title']
          ranges[property_page.title] = ranges[property_page.title] + [namespace]
        end
      end
    end

    # raise

    page.triples.each do |triple|
      if domains[triple.predicate].length > 0 && !domains[triple.predicate].include?(page.namespace) && !domains[triple.predicate].include?('Any')
        errors << "Invalid domain for #{triple.predicate}::#{triple.object}, '#{triple.predicate}' has domain #{domains[triple.predicate].join(', ')}"
      end

      object_namespace = PageModule.retrieve_namespace_and_title(triple.object)['namespace']
      if ranges[triple.predicate].length > 0 && !ranges[triple.predicate].include?(object_namespace) && !ranges[triple.predicate].include?('Any')
        errors << "Invalid range for #{triple.predicate}::#{triple.object}, '#{triple.predicate}' has range #{ranges[triple.predicate].join(', ')}"
      end
    end

    [errors, []]
  end

  def validate_sections(schema_triples, triple_predicates, section_names)
    errors = []
    warnings = []
    schema_triples.each do |triple|
      namespace, title = triple.object.split(':')
      if namespace == 'Section'
        unless section_names.include?(title)
          if triple.predicate.include?('Optional')
            warnings << "Optional section #{title} is not used"
          else
            errors << "Section #{title} is missing"
          end
        end
      elsif namespace == 'Property'
        unless triple_predicates.include?(title)
          if triple.predicate.include?('Optional')
            warnings << "Optional property #{title} is not used"
          else
            errors << "Property #{title} is missing"
          end
        end
      else
        raise
      end
    end

    [errors, warnings]
  end


end
