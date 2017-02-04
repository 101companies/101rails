json.extract! chapter, :id, :url, :title, :content, :check_sum, :book, :created_at, :updated_at
json.url chapter_url(chapter, format: :json)