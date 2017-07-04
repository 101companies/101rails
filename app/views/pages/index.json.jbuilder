json.array! @pages do |page|
  json.namespace page.namespace
  json.title page.title
  json.raw_content page.raw_content
  json.id page.id
  json.sections page.db_sections

  json.triples page.triples, :predicate, :object
end
