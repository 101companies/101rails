class PageChange

  require 'differ/string'

  include Mongoid::Document
  include Mongoid::Timestamps::Created

  belongs_to :page
  belongs_to :user

  field :title, type: String
  field :namespace, type: String
  field :raw_content, type: String

  field :new_title, type: String
  field :new_namespace, type: String
  field :new_raw_content, type: String

  field :pages_changed_by_renaming, type: Array, :default => []

  def self.propagation_status_options
    ['Failed to propagate', 'Successfully propagated', 'Not propagated']
  end
  field :propagation_status, type: String, :default => 'Not propagated'

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
