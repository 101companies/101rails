class PageChange

  require 'differ/string'

  include Mongoid::Document
  include Mongoid::Timestamps::Created

  belongs_to :page
  belongs_to :user

  field :title, type: String
  field :namespace, type: String
  field :raw_content, type: String

  def self.get_diff(first_content, second_content)
    Differ.format = :html
    Differ.diff_by_word(first_content, second_content).to_s.html_safe
  end

end
