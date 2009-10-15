namespace :db do

  desc "add some log. By default add 100 log. You can define number with NB"
  task :populate => :environment do
    begin
      require "randexp"
      require "machinist"
      require File.join(Rails.root, '/spec/blueprints.rb')
    rescue LoadError => e
      puts 'You need gem randexp, machinist and machinist_mongomapper'
      raise e
    end

    nb = ENV['NB'] || 100
    nb.to_i.of { 
      MLogger.make
      print '.'
      STDOUT.flush
    }
  end
end


