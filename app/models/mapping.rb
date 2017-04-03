class Mapping < ApplicationRecord
  belongs_to :chapter
  belongs_to :page

  def chapter_name
    @chapter_name ||= chapter.name
  end

  def book_title
    @book_title ||= chapter&.book&.name
  end

  def chapter_url
    @chapter_url ||= chapter.url
  end

  def page_title
    @page_title ||= page&.full_title
  end

end
