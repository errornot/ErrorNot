require 'machinist/mongomapper'

Sham.composant { /\w+/.gen }
Sham.name { /\w+/.gen }
Sham.message { /[:paragraph:]/.gen }

User.blueprint do
  email { /\w+@\w+.com/.gen }
  password {  'tintinpouet' }
  password_confirmation { 'tintinpouet' }
end

def make_user
  user = User.make
  user.confirmation_sent_at = Time.now
  user.confirmed_at = Time.now
  user.save!
  user
end

Error.blueprint do
  project { Project.make }
  message
  resolved { false }
  raised_at { Time.now }
  backtrace ['[PROJECT_ROOT]/vendor/gems/mongo-0.18/lib/../lib/mongo/types/objectid.rb:73:in `from_string',
  '[PROJECT_ROOT]/vendor/gems/mongo_mapper-0.6.4/lib/mongo_mapper/finder_options.rb:64:in `to_mongo_criteria']
end

Project.blueprint do
  name
  members { [Member.new(:user => make_user, :admin => true)] }
end
