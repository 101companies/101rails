class PageChange  < ActiveRecord::Base

  require 'differ/string'

  belongs_to :page
  belongs_to :user

  def self.get_by_id(id)
    PageChange.where(id: id).first
  end

  def self.get_diff(first_content, second_content)
    Differ.format = :html
    Differ.diff_by_char(first_content, second_content).to_s.html_safe
  end

end
