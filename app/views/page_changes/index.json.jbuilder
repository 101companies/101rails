json.array! @changes do |change|
  json.namespace change.namespace
  json.title change.title
  json.raw_content change.raw_content
  json.id change.id
  json.created_at change.created_at
end
