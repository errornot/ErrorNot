def make_user(user_hash={})
  user = Factory.build(:user)
  user.update_attributes(user_hash)
  user.confirmation_sent_at = Time.now
  user.confirmed_at = Time.now
  user.save!
  user
end

Factory.define(:user) do |u|
  u.email { /\w+@\w+.com/.gen }
  u.password 'tintinpouet'
  u.password_confirmation 'tintinpouet'
end

Factory.define(:error) do |e|
  e.project { Factory(:project) }
  e.message { /[:paragraph:]/.gen }
  e.resolved false
  e.raised_at { Time.now }
  e.backtrace ['[PROJECT_ROOT]/vendor/gems/mongo-0.18/lib/../lib/mongo/types/objectid.rb:73:in `from_string',
  '[PROJECT_ROOT]/vendor/gems/mongo_mapper-0.6.4/lib/mongo_mapper/finder_options.rb:64:in `to_mongo_criteria']
end

Factory.define(:project) do |pr|
  pr.name { /\w+/.gen }
  pr.members { [Member.new(:user => make_user, :admin => true)] }
end

def make_project_with_admin(user=make_user)
  Factory(:project, :members => [Member.new(:user => user, :admin => true)])
end

