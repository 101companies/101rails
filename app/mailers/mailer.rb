class Mailer < ActionMailer::Base
  default from: "101companies@gmail.com"

  def created_contribution(contribution)
    @request = contribution
    mail(to: @request.user.email, subject: "Your have submitted contribution '#{@request.page.title}'")
  end

  def analyzed_contribution(contribution)
    @request = contribution
    mail(to: @request.user.email, subject: "Your contribution #{@request.page.title} has been analyzed")
  end

end
