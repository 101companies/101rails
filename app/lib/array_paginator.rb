class ArrayPaginator

  def initialize(array)
    @page = 0
    @array = array
    @per = 100
  end

  def to_a
    offset = @page * @per
    @array[offset, @per]
  end

  def per(per)
    @per = per
    self
  end

  def page(page)
    @page ||= page
    self
  end

end
