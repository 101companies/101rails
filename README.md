#101companies-wiki

[![](https://codeclimate.com/github/101companies/101rails.png)](https://codeclimate.com/github/101companies/101rails) [![Dependency Status](http://www.versioneye.com/user/projects/51b5a94f83548c000200dda1/badge.png)](http://www.versioneye.com/user/projects/51b5a94f83548c000200dda1)

This application was generated with the [rails_apps_composer](https://github.com/RailsApps/rails_apps_composer) gem provided by the [RailsApps Project](http://railsapps.github.com/).

##Requirements

This application requires:

*   Ruby
*   Rails
*   MongoDB
*   Node.js

##Development

*   Template Engines: ERB, HAML
*   Front-end Frameworks: jQuery, Backbone.js, Twitter Bootstrap
*   Authentication: Omniauth
*   Authorization: Cancan

##Email

The application is configured to send emails through a Gmail account.

##Getting Started

###Preparation for Ubuntu only

Before starting work with the application, you need to install dependecies:

    apt-get install curl nodejs build-essenstial libxslt-dev libxml2-dev mongodb

If you are using Ubuntu, you can install ruby via [rvm](http://rvm.io)

    rvm install 2.0.0-p247
    rvm use 2.0.0-p247 --default

###Preparation for OSX only

Install ruby using [rvm](http://rvm.io) or [rbenv](https://github.com/sstephenson/rbenv/)

And install dependencies for project:

    brew install mongodb node

###Common part of installation

At first you need to install gem bundler.

    gem install bundler

Now you need go to the project folder und install app:

    bundle install --path vendor/bundle

After installing mongodb you need to start it and then launch application with:

    bundle exec rails server

###Local admin rights

To be signed in you need to have github account with public email and enter your name in github profile.

![](http://101companies.org/assets/github-public-email-3ed71b5549eed5cd7235804f3e0054f9.png)

If you have been successfully signed in, you can set another role to your user:

    bundle exec rake change_role

You will be asked for your email and new role.

Just type email from your github account and role ‘admin’ (or 'editor', 'guest')

##Contributing

If you make improvements to this application, please share with others.

*   Fork the project on GitHub.
*   Make your feature addition or bug fix.
*   Commit with Git.
*   Send a pull request.

If you add functionality to this application, create an alternative implementation, or build an application that is similar, please contact me and I’ll add a note to the README so that others can find your work.
