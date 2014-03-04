class PageChange

  require 'differ/string'

  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :title, type: String
  field :namespace, type: String
  field :raw_content, type: String

  field :git_commit_message, type: String
  field :git_commit_hash, type: String
  field :propagation_status, type: String

  belongs_to :page
  belongs_to :user

  has_many :related_changed_pages, :class_name => 'Page'

  #before_save do
  #  PageModule.write_all_pages_to_hard_disk
    # TODO: git commit
  #end

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
