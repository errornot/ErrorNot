# ErrorNot

A service to be sure that all errors in your apps are raised. You can push errors by POST request
and then do their follow up (pending, resolved, etc) in the app.

 - Info and screenshots are available on the [AF83 dev blog](http://dev.af83.com/git/launch-errornot-english-version/2010/03/24).
 - [Here is a demo site to preview and send your own errors to](http://demo.errornot.af83.com/).

 - On IRC: FreeNode / #errornot
 - Mailing list: errornot@googlegroups.com, http://groups.google.com/group/errornot

## Features

ErrorNot :

* Is multi-project and multi-user (read / comment / edit follow-up)
* Allows you to set a status to the error (pending, etc)
* Allows you to comment the errors
* Notifies you by email every time a new error is raised
* Supports notification via a digest. The frequency of notification is set by a cron


## Authors
  ErrorNot has been started by Cyril Mougel (shingara) as he was working for AF83.
  Cyril Mougel and AF83 both continue to contribute to this project.

  Many thanks to the ErrorNot or ErrorNot notifiers contributors:
    - François de Metz (francois2metz) for the PHP plugin
    - Cyril Mougel (shingara) for the Rails plugin
    - Pierre Ruyssen (virtuo) for the Python plugin


## Requirements

You will need

 - Ruby of 1.8.6 or greater
 - Rails 2.3.5
 - MongoMapper 0.7.1
 - A MongoDB 1.0.1 or greater

## Installing

 - fetch source from our github account ( git clone git://github.com/AF83/ErrorNot.git )
 - install rails gem ( gem install rails -v2.3.5 )
 - install all gems required by ErrorNot ( rake gems:install )
 - configure your database
   - copy config/database.yml.sample to config/database.yml
   - update config/database.yml with your database connection and the table name
 - configure your email settings
   - copy config/email.yaml.sample to config/email.yml
   - update it with email configuration (sendmail or smtp information)
 - Start the server in production mode : ruby script/server -e production
 - If you want that your user can be received their notification by digest, you need
   add the rake task `RAILS_ENV=production rake notify:digest` in your crontab
 - You can now register your self /user/new
 - Have fun

## Using

  Depending of what is more convenient to your project, you can use one of the ErrorNot notifiers to send errors to ErrorNot:

   - The [Rails errornot notifier](http://github.com/shingara/errornot_notifier)
   - The [PHP errornot notifier](http://github.com/francois2metz/php-errornot)
   - The [Python errornot notifier](http://bitbucket.org/virtuo/errornot_notifier_py/wiki/Home) with support for WSGI applications (Django, Pylons...)

## Development

If you want to hack ErrorNot, you need launch all Test. This test is made with rspec.

You can install all gems needed with command :

 - RAILS_ENV=test rake gems:install

Now you can launch spec :

 - rake spec

If you want to fill your Database with a lot of fake data, you can launch the task :

 - rake db:populate:default

This task depends of :

 - rake db:populate:users
 - rake db:populate:projects
 - rake db:populate:errors
 - rake db:populate:comments
 - rake db:populate:same_errors

When you have generated some data, you can fetch a user account by console and use the
default password 'tintinpouet'

$ script/console
> Project.first.members.first.email
=> "pinguidity@yachtdom.com"

Every project has one related email. You can use this email to log in.

## License

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see [http://www.fsf.org/licensing/licenses/agpl-3.0.html](http://www.fsf.org/licensing/licenses/agpl-3.0.html)

