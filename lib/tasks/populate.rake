namespace :db do

  namespace :populate do

    desc "default"
    task :default => [:projects, :errors]

    desc "add some project by default 10 projects"
    task :projects => :environment do
      begin
        require "randexp"
        require "machinist"
        require File.join(Rails.root, '/spec/blueprints.rb')
      rescue LoadError => e
        puts 'You need gem randexp, machinist and machinist_mongomapper'
        raise e
      end
      nb = ENV['NB'] || 10
      nb.to_i.of {
        Project.make
        print '.'
        STDOUT.flush
      }

    end

    desc "add some errors on all project. By default add 1000 errors. You can define number with NB"
    task :errors => :environment do
      begin
        require "randexp"
        require "machinist"
        require File.join(Rails.root, '/spec/blueprints.rb')
      rescue LoadError => e
        puts 'You need gem randexp, machinist and machinist_mongomapper'
        raise e
      end

      nb = ENV['NB'] || 1000
      nb.to_i.of {
        Error.make(:project => Project.all.rand)
        print '.'
        STDOUT.flush
      }
    end
  end
end


