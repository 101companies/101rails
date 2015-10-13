class UpdateRepoForPage

  def execute!()

  end

  private

  def get_page()
    @get_page ||= GetPage.new
  end

end
