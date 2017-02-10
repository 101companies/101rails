class Chapter < ApplicationRecord
  belongs_to :book

  validates :title, presence: true
  validates :url, presence: true

  def download_content
    content = Net::HTTP.get(url)
  end

  def clean_html_content
    content = text = Html2Text.convert(content)
  end

  def stem
    stemmer = Stemmer.new
    content = stemmer.stem(content)
  end

  def find_frequencies
    words = stemmer.split /^\d+/
    result = {}
    words.each do |word|
      result[word] ||= 0
      result[word] += 1
    end
    result
  end

  def remove_common_english_terms

  end



end
