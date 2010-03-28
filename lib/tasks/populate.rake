namespace :db do

  desc "drop the database"
  task :drop => [:environment] do
    MongoMapper.database.collections.each do |coll|
      coll.remove
    end
  end

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
      print "\n"
      STDOUT.flush
    end

    desc "default"
    task :default => [:users, :projects, :errors, :comments, :same_errors]

    desc "add some user activated"
    task :users => :environment do
      require_factories
      puts 'create some users'
      generate(10) do
        make_user
      end
    end

    desc "add some project by default 10 projects"
    task :projects => :environment do
      require_factories
      puts 'create some projects'
      generate(10) do
        make_project_with_admin(User.all.rand)
      end
    end

    desc "add some errors on all project. By default add 1000 errors. You can define number with NB"
    task :errors => :environment do
      require_factories
      puts 'create some errors'
      generate(1000) do
        Factory(:error, :project => Project.all.rand)
      end
    end

    desc "Add some comment on all errors by default add 10000 comments. You can define number with NB"
    task :comments => :environment do
      require 'randexp'
      puts 'create some comments'
      error_ids = Error.all.map(&:id)
      generate(2_000) do
        error = Error.find(error_ids.rand)
        user = error.project.members.rand.user
        error.comments.build(:user => user,
                             :text => /[:paragraph:]/.gen)
        error.save!
      end
    end

    desc "add some same errors on all project. By default add 3000 errors. You can define number with NB"
    task :same_errors => :environment do
      require_factories
      puts 'create some same errors'
      errors_ids = Error.all.map(&:id)
      generate(3000) do
        error = Error.find(errors_ids.rand)
        error_attribute = Factory.build(:error, :project => error.project,
               :message => error.message,
               :backtrace => error.backtrace,
               :raised_at => error.last_raised_at + 1.minute).attributes
        error.same_errors.build.update_attributes(error_attribute)
        error.save!
      end
    end

    task :full_same_error => :environment do
      require_factories
      pr = Project.first
      puts "project #{pr.id}"
      err = Error.new JSON.parse(File.read('error.json'))
      err.project = pr
      err.save!
      puts "error #{err.id}"
      generate(2_000) do
        e = pr.error_with_message_and_backtrace(err.message, err.backtrace)
        e.request = err.request
        e.session = err.session
        e.raised_at = Time.now
        e.save!
      end
    end
  end
end


