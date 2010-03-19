
/var/www/errornot/gem/bin/rake -f /var/www/errornot/site/prod/Rakefile db:drop
/var/www/errornot/gem/bin/rake -f /var/www/errornot/site/prod/Rakefile db:populate:users

# Reload server:
/usr/bin/touch /var/www/errornot/site/prod/tmp/restart.txt

/var/www/errornot/gem/bin/rake -f /var/www/errornot/site/prod/Rakefile db:populate:projects
/var/www/errornot/gem/bin/rake -f /var/www/errornot/site/prod/Rakefile db:populate:errors
/var/www/errornot/gem/bin/rake -f /var/www/errornot/site/prod/Rakefile db:populate:comments
/var/www/errornot/gem/bin/rake -f /var/www/errornot/site/prod/Rakefile db:populate:same_errors


