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

  field :related_changed_pages, type: Array

  #before_save do
  #  PageModule.write_all_pages_to_hard_disk
    # TODO: git commit
  #end

  def self.create_track(user, commit_message, page=nil, changed_pages=nil)
    new_page_change = PageChange.new

    new_page_change.page  = page
    new_page_change.raw_content = page.raw_content
    new_page_change.user = user
    new_page_change.git_commit_message = commit_message

    if !changed_pages.nil? && changed_pages.count != 0
      new_page_change.related_changed_pages = changed_pages
    end

    if new_page_change
      new_page_change.raw_content = page.raw_content
      new_page_change.title = page.title
      new_page_change.namespace = page.namespace
    end

    return new_page_change
  end

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
