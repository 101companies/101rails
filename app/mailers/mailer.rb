class Mailer < ActionMailer::Base
  default from: "101companies@gmail.com"

  def created_contribution(contribution)
    @page = contribution
    mail(to: @page.contributor.email, subject: "Your have submitted contribution '#{@page.title}'")
  end

  def analyzed_contribution(contribution)
    @page = contribution
    mail(to: @page.contributor.email, subject: "Your contribution #{@page.title} has been analyzed")
  end

end
