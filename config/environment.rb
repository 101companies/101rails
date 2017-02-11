# Load the rails application
require File.expand_path('../application', __FILE__)

Mime::Type.register "text/turtle", :ttl
Mime::Type.register "text/n3", :n3

# Initialize the rails application
Wiki::Application.initialize!
