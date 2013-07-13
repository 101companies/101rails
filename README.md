#101companies-wiki

[![](https://codeclimate.com/github/101companies/101rails.png)](https://codeclimate.com/github/101companies/101rails) [![Dependency Status](http://www.versioneye.com/user/projects/51b5a94f83548c000200dda1/badge.png)](http://www.versioneye.com/user/projects/51b5a94f83548c000200dda1)

This application was generated with the [rails_apps_composer](https://github.com/RailsApps/rails_apps_composer) gem provided by the [RailsApps Project](http://railsapps.github.com/).

##Requirements

This application requires:

*   Ruby
*   Rails
*   MongoDB
*   Redis (for production mode)

##Development

*   Template Engines: ERB, HAML
*   Front-end Frameworks: jQuery, backbone.js, Bootstrap
*   Authentication: Omniauth
*   Authorization: Cancan

##Email

The application is configured to send emails using a Gmail account.

##Getting Started

###Preparation for Ubuntu only

Before installing all, you need to install some dependecies:

    sudo apt-get install redis-server curl nodejs build-essenstial libxslt-dev libxml2-dev mongodb

If you are using Ubuntu, you can install ruby via [rvm](http://rvm.io)

    rvm install 1.9.3-p429
    rvm use 1.9.3-p429 --default

###Preparation for OSX only

Install ruby (version 1.9.3) using [rvm](http://rvm.io) or [rbenv](https://github.com/sstephenson/rbenv/)

And install dependencies for project:

    brew install mongodb node redis

###Common part of installation

First of all you need to install gem bundler.

    sudo gem install bundler

Now you need go to project folder.

If you want to have all gems ready per project only:

    bundle install --path vendor/bundle

To apply index for mongodb you need to execute

    bundle exec rake db:mongoid:create_indexes

Indexes are using for unique keys in db.

Creating indexes need to be done after adding any new model with indexes or changing old models with indexes.

After installing mongodb start this database and then launch application with:

    bundle exec rails server

If you want to see all models of app you need to execute next:

    bundle exec railroady -M -e app/models/ability.rb | neato -Tpng &gt; models.png

It will be generated a picture in root of the app named **models.png**

###Local admin rights

To be signed in you need to have github account with public email.

If you have been successfully signed in, you can set another role to your user:

    bundle exec rake change_role

You will be asked about your email and new role.

Just type email from your github account and role ‘admin’

##Contributing

If you make improvements to this application, please share with others.

*   Fork the project on GitHub.
*   Make your feature addition or bug fix.
*   Commit with Git.
*   Send the author a pull request.

If you add functionality to this application, create an alternative implementation, or build an application that is similar, please contact me and I’ll add a note to the README so that others can find your work.
