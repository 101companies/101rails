class ValidatePage
  include SolidUseCase
  steps :validate

  SCHEMA_PREDICATES = [
    'hasMandatory',
    'hasOptional'
  ]

  def validate(params)
    page = params[:page]

    if page.present?
      namespace_page = PageModule.find_by_full_title("Namespace:#{page.namespace}")
      errors = []

      unless namespace_page.present?
        errors << "No namespace page found for #{page.namespace}"
        params[:errors] = errors
        return continue(params)
      end

      schema_triples = namespace_page.triples.where(predicate: SCHEMA_PREDICATES)
      section_names = page.section_names
      triple_predicates = page.triples.pluck(:predicate)

      schema_triples.each do |triple|
        namespace, title = triple.object.split(':')
        if namespace == 'Section'
          unless section_names.include?(title)
            errors << "Section #{title} is missing"
          end
        elsif namespace == 'Property'
          unless triple_predicates.include?(title)
            errors << "Property #{title} is missing"
          end
        else
          raise
        end
      end

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
    end

    continue(params)
  end


end
