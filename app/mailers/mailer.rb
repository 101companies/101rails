class Mailer < ActionMailer::Base
  default from: "101companies@gmail.com"

  def user_created_contribution(contribution, email)
    @contribution = contribution
    mail(to: email, subject: "Your have submitted contribution '#{@contribution.title}'")
  end

  def admin_created_contribution(contribution)
    @contribution = contribution
    mail(to: "admin@101companies.org", subject: "A new contribution '#{@contribution.title}' has been submitted")
  end

  def contribution_wikipage_verfied(contribution, email)
    @contribution = contribution
    mail(to: email, subject: "Your submitted contribution '#{@contribution.title}' has been verified")
  end

  def contribution_wikipage_denied(contribution, email)
    @contribution = contribution
    mail(to: email, subject: "Your submitted contribution '#{@contribution.title}' has been denied")
  end

end
