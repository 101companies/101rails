class ListUnverifiedPages
  include SolidUseCase

  steps :get_pages

  def get_pages(params)
    params[:pages] = Page.where(verified: false)

    continue(params)
  end

end
