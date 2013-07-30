class Mailer < ActionMailer::Base
  default from: "101companies@gmail.com"

  def created_contribution(contribution)
    @contribution = contribution
    mail(to: @contribution.user.email, subject: "Your have submitted contribution '#{@contribution.title}'")
  end

  def analyzed_contribution(contribution)
    @contribution = contribution
    mail(to: @contribution.user.email, subject: "Your contribution #{@contribution.title} has been analyzed")
  end

end
