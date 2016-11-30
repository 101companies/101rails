class PageChange  < ActiveRecord::Base

  require 'differ/string'

  # include Mongoid::Document
  # include Mongoid::Timestamps::Created

  # rails_admin do
  #   list do
  #     field :title
  #     field :namespace
  #     field :created_at
  #   end
  # end

  belongs_to :page
  belongs_to :user

  # field :title, type: String
  # field :namespace, type: String
  # field :raw_content, type: String

  def self.get_by_id(id)
    if id.nil?
      return nil
    end
    begin
      PageChange.find(id)
    rescue
      nil
    end
  end

  def self.get_diff(first_content, second_content)
    Differ.format = :html
    Differ.diff_by_char(first_content, second_content).to_s.html_safe
  end

end
