class RenameToDetails < ActiveRecord::Migration[5.0]
  def change
    Page.where(namespace: 'Concept').find_each do |page|
      page.raw_content = page.raw_content.gsub('== Summary ==', '== Details ==')
      page.save!
    end

    Page.where(namespace: 'Script').find_each do |page|
      page.raw_content = page.raw_content.gsub('== Summary ==', '== Description ==')
      page.save!
    end
  end
end
