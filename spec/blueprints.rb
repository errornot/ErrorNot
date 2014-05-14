def make_user(user_hash={})
  user = Factory.build(:user)
  user.update_attributes(user_hash)
  user.confirmation_sent_at = Time.now
  user.confirmed_at = Time.now
  user.save!
  user
end

Factory.define(:user) do |u|
  u.email { /\w+@\w+\.com/.gen }
  u.password 'tintinpouet'
  u.password_confirmation 'tintinpouet'
end

Factory.define(:error) do |e|
  e.project { Factory(:project) }
  e.message { /[:paragraph:]/.gen }
  e.resolved false
  e.raised_at { (1..500).to_a.random_element.day.ago }
  e.backtrace ['[PROJECT_ROOT]/vendor/gems/mongo-0.18/lib/../lib/mongo/types/objectid.rb:73:in `from_string',
  '[PROJECT_ROOT]/vendor/gems/mongo_mapper-0.6.4/lib/mongo_mapper/finder_options.rb:64:in `to_mongo_criteria']
  e.request {
    {'rails_root' => /\/path\/to\/\w+/.gen,
        'url' => /http:\/\/localhost\/\w+/.gen,
        'params' => {
          'action' => /\w+/.gen,
          'id' => /\d{1,5}/.gen,
          'controller' => 'groups'}}
  }
end

Factory.define(:project) do |pr|
  pr.name { /\w+/.gen }
  pr.members { [Member.new(:user => make_user, :admin => true)] }
end

def make_project_with_admin(user=make_user)
  Factory(:project, :members => [Member.new(:user => user, :admin => true)])
end

def saved_project_with_admins_and_users(admins, simple_users=[])
  project = Factory(:project,
                    :members => admins.map{|u|Member.new(:user => u, :admin => true)} + \
                                simple_users.map{|u|Member.new(:user => u, :admin => false)})
  project.save!
  project
end


def make_error_with_data(datas)
  count = datas.delete(:count) || 0
  nb_comments = datas.delete(:nb_comments) || 0
  error = Factory(:error, datas)
  nb_comments.times {
    error.comments.build(:user => error.project.members.random_element.user,
                         :text => /[:paragraph:]/.gen)
  }
  error.save!
  count.times { error.same_errors.build(:raised_at => error.raised_at).save }
  error
end

def add_embedded_error(error)
  error_2 = Factory.build(:error, :project => error.project,
                          :message => error.message,
                          :backtrace => error.backtrace)
  error_embedded = error.project.error_with_message_and_backtrace(error_2.message,
                                                                  error_2.backtrace)
  error_embedded.update_attributes(error_2.attributes)
  error.reload
end

##
# Generate a member from user define by Factory and Project too
#
# Options send by args update only member model
#
def make_member(options)
  user = make_user
  member = Member.new({:user => user,
                      :notify_by_digest => false,
                      :admin => true}.merge(options))
  project = Factory(:project, :members => [member])
  member = project.members.first
end
