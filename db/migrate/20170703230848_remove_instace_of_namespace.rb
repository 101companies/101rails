class RemoveInstaceOfNamespace < ActiveRecord::Migration[5.0]
  def change
    Page.find_each do |page|
      page.raw_content = page.raw_content.gsub(/\[\[instanceOf::Namespace:[^(\])]+\]\]/, '')
      page.save!
    end
  end
end
