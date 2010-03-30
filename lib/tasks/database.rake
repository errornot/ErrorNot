namespace :db do
  desc 'Migrate the database'
  task :mongo_migrate => [:environment] do
    require 'db/migrate/001_extract_same_error'
  end
end
