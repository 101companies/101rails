class UnverifyPage
  include SolidUseCase
  steps GetPage, :validate, :unverify_page, LogVerificationEvent

  def validate(params)
    page = params[:page]

    unless page.verified
      fail(:page_already_unverified)
    else
      continue(params)
    end
  end

  def unverify_page(params)
    page = params[:page]

    page.verified = false
    page.save!

    params[:page] = page
    continue(params)
  end

end
