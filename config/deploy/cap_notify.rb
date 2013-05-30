=begin

Taken from here: https://gist.github.com/johnthethird/955917

Capistrano deployment email notifier for Rails 3

Do you need to send email notifications after application deployments?

Christopher Sexton developed a Simple Capistrano email notifier for rails. You can find details at http://www.codeography.com/2010/03/24/simple-capistrano-email-notifier-for-rails.html.

Here is Rails 3 port of the notifier.

The notifier sends an email after application deployment has been completed.

How to use it?

 1. Add this file to config/deploy folder.
 2. Update the file with your google credentials and from email address.
 3. Add the following content to config/deploy.rb.

    require 'config/deploy/cap_notify.rb'

    # add email addresses for people who should receive deployment notifications
    set :notify_emails, ["EMAIL1@YOURDOMAIN.COM", "EMAIL2@YOURDOMAIN.COM"]

    after :deploy, 'deploy:send_notification'

    # Create task to send a notification
    namespace :deploy do
      desc "Send email notification"
      task :send_notification do
        Notifier.deploy_notification(self).deliver
      end
    end

 4. Update deploy.rb with destination email addresses for the notifications.
 5. To test run this command:

    cap deploy:send_notification

=end

require "action_mailer"

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :enable_starttls_auto => true,
  :tls => false,
  :address => "smtp.gmail.com",
  # TODO: if openssl works -> change to 587 and set :tls => true
  :port => 25,
  :domain => "gmail.com",
  :authentication => "plain",
  :user_name => ENV['GMAIL_USERNAME'],
  :password => ENV['GMAIL_PASSWORD']
}

class Notifier < ActionMailer::Base
  default :from => ENV['GMAIL_USERNAME']
  def deploy_notification(cap_vars)
    now = Time.now
    msg = "Performed a deploy operation on #{now.strftime("%m/%d/%Y")} at #{now.strftime("%I:%M %p")} for 101rails"
    mail(:to => cap_vars.notify_emails,
         :subject => "Deployed 101rails") do |format|
      format.text { render :text => msg}
      format.html { render :text => "<p>" + msg + "<\p>"}
    end
  end
end
