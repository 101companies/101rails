class ApiPagesController < ApplicationController
  layout false

  def show
    result = GetPage.run(full_title: params[:id]).match do

      success do |result|
        render locals: { page: result[:page] }, format: :json
      end

      failure do
        render json: { message: 'some error occured' }
      end
    end
  end
end
