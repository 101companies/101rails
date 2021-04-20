json.extract! chapter, :id, :book_id, :name, :url, :checksum, :created_at, :updated_at
json.url chapter_url(chapter, format: :json)
