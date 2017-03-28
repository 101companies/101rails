# 101companies-wiki

[![](https://codeclimate.com/github/101companies/101rails.png)](https://codeclimate.com/github/101companies/101rails) [![Dependency Status](http://www.versioneye.com/user/projects/51b5a94f83548c000200dda1/badge.png)](http://www.versioneye.com/user/projects/51b5a94f83548c000200dda1)

101wiki web app written using Ruby on Rails.

## Software dependencies

Before starting work with the application, you need to install such dependencies, if you are using Ubuntu:

    apt-get install postfix curl git-core zlib1g-dev libssl-dev libreadline-dev
      libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev postgresql-server-dev-all postgresql-contrib build-essential nodejs ruby2.3 ruby2.3-dev htop postgresql-9.5 postgresql-client bundler

## Ruby

With OSX you already have Ruby.

If you are using Ubuntu you can install ruby via [rvm](http://rvm.io) or [rbenv](https://github.com/sstephenson/rbenv/).

This app was tested with ruby 2.3.0-2.3.3.

## Installing the app

At first you need to install **bundler** gem.

    gem install bundler

Now you need go to the project folder und install app:

    bundle install

You need a postgres dump which must be acquired from the 101companies admins.
If you have a dump load it like this:

    cat wiki_db.gz | gunzip | psql wiki_development

After setting up the database you need to start it and then launch application with:

    bin/rails s

## Admin rights

To be signed in you need to have GitHub account with **name** and **public email** in GitHub profile.

![](app/assets/images/readme_profile.png)

If you have been successfully signed in, you can set another role to your user:

    bundle exec rake change_role

You will be asked for your email and new role. Just type email from your GitHub account and role **admin**.

## Keys

You need some keys of 101companies before you can start to work.
You can ask [@avaranovich](https://github.com/avaranovich), [@rlaemmel](https://github.com/rlaemmel) or
[@tschmorleiz](https://github.com/tschmorleiz) for this password.

For successful work with project in development mode you need to define next ENV variables in your .bashrc/.zshrc, for deployment, place them inside /etc/environment.

    export SLIDESHARE_API_KEY=
    export SLIDESHARE_API_SECRET=
    export GMAIL_PASSWORD=
    export GITHUB_KEY_DEV=
    export GITHUB_SECRET_DEV=
    export MONGODB_USER=
    export MONGODB_PWD=
    
## Contributing

If you make improvements to this application, please share with others.

*   Fork the project on GitHub.
*   Make your feature addition or bug fix.
*   Commit with Git.
*   Send a pull request.

If you add functionality to this application, create an alternative implementation, or build an application that is similar, please contact me and I’ll add a note to the README so that others can find your work.
