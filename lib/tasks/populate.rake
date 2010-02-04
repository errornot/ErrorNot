namespace :db do

  namespace :populate do

    def require_factories
      begin
        require "randexp"
        require 'factory_girl'
        require File.join(Rails.root, '/spec/blueprints.rb')
      rescue LoadError => e
        puts 'You need gem randexp and factory_girl'
        raise e
      end
    end

    # Generate a number of time
    # the block send
    def generate(nb)
      nb = ENV['NB'] || nb
      nb.to_i.of {
        yield
        print '.'
        STDOUT.flush
      }
    end

    desc "default"
    task :default => [:users, :projects, :errors]

    desc "add some user activated"
    task :users => :environment do
      require_factories
      generate(10) do
        make_user
      end

    end

    desc "add some project by default 10 projects"
    task :projects => :environment do
      require_factories
      generate(10) do
        make_project_with_admin(User.all.rand)
      end
    end

    desc "add some errors on all project. By default add 1000 errors. You can define number with NB"
    task :errors => :environment do
      require_factories
      generate(1000) do
        Factory(:error, :project => Project.all.rand)
      end
    end
  end
end


