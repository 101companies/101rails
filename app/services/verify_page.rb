class VerifyPage
  include SolidUseCase
  steps GetPage, :validate, :verify_page, LogVerificationEvent

  def validate(params)
    page = params[:page]

    if page.verified
      fail(:page_already_verified)
    else
      continue(params)
    end
  end

  def verify_page(params)
    page = params[:page]

    page.verified = true
    page.save!

    params[:page] = page
    continue(params)
  end

end
