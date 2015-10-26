class ApiPagesController < ApplicationController
  layout false

  def show
    result = show_page.execute!(params[:id], current_user)
    render locals: { page: result.page }, format: :json
  end

  private

  def show_page
    @show_page ||= ShowPage.new(logger, Rails.configuration.books_adapter)
  end

end
