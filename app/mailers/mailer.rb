class Mailer < ActionMailer::Base
  default from: "101companies@gmail.com"

  def created_contribution(contribution)
    @contribution_page = contribution
    mail(to: @contribution_page.contributor.email, subject: "Your have submitted contribution '#{@contribution_page.title}'")
  end

  def analyzed_contribution(contribution)
    @contribution_page = contribution
    mail(to: @contribution_page.contributor.email, subject: "Your contribution #{@contribution_page.title} has been analyzed")
  end

end
