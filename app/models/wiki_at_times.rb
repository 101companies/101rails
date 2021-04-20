class WikiAtTimes < Page
  self.table_name = 'wiki_at_times'

  def self.page_at_time(namespace, title, time)
    object = where('valid_from < ?', time).where(namespace: namespace, title: title).order("valid_from - '#{time.to_s(:db)}' asc").last
    object = PageModule.find_by(full_title: "#{namespace}:#{title}") if object.nil?
    object
  end

  private

  def preparing_the_page; end

  def readonly?
    true
  end
end
