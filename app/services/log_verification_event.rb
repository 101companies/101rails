class LogVerificationEvent
  include SolidUseCase
  steps :log_verification_event

  def log_verification_event(params)
    user = User.find(params[:user_id])
    page = params[:page]

    change_event = PageVerification.create!(
      user: user,
      page: page,
      from_state: !page.verified,
      to_state: page.verified
    )

    params[:change_event] = change_event

    Mailer.contribution_wikipage_verfied(page)

    continue(params)
  end

end
