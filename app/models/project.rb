class Project
  include MongoMapper::Document

  key :api_key, String, :required => true, :index => true
  key :name, String, :required => true

  key :nb_errors_reported, Integer, :default => 0
  key :nb_errors_resolved, Integer, :default => 0
  key :nb_errors_unresolved, Integer, :default => 0

  many :error_reports, :class_name => 'Error' do
    def not_send_by_digest_since(date)
      all(:unresolved_at => {'$gt' => date.utc},
          :resolved => false,
          :order => 'last_raised_at')
    end
  end

  many :members

  validate :need_members
  validate :need_admin_members

  # TODO: find an equivalent in ActiveModel
  # include_errors_from :members

  ## CALLBACK
  before_validation :gen_api_key, :on => :create
  before_save :update_members_data

  def add_admin_member(user)
    members.build(:user => user, :admin => true)
  end

  def make_user_admin!(user)
    member_obj = member(user)
    return false unless member_obj.status == Member::VALIDATE
    member_obj.admin = true
    save
  end

  def unmake_user_admin!(user)
    member(user).admin = false
    save
  end

  def member_include?(user)
    members.any?{|member| member.user_id == user.id}
  end

  def admin_member?(user)
    members.any?{|member| member.user_id == user.id && member.admin? }
  end

  def remove_member!(data={:user => nil, :email => nil})
    if data.key? :email
      members.delete_if{ |member| member.email == data[:email] }
    elsif data.key? :user
      members.delete_if{ |member| member.user_id.to_s == data[:user].id.to_s }
    end
    save
  end

  def update_nb_errors
    self.nb_errors_reported = error_reports.count
    self.nb_errors_unresolved = error_reports.count(:resolved => false)
    self.nb_errors_resolved = error_reports.count(:resolved => true)
    self.save!
  end

  ##
  # Add member to this project by emails.
  #
  # If user already exist with this email. Add it.
  # instead send an email to create his account
  #
  # @params[String] list of emails separate by comma
  # @return true if works
  def add_member_by_email(emails)
    emails.split(',').each do |email|
      user = User.first(:email => email.strip)
      if user
        members.build(:user => user,
                      :admin => false)
      else
        members.build(:email => email.strip,
                      :admin => false)
        UserMailer.project_invitation(email.strip, self).deliver
      end
    end
    save!
  end

  def member(user)
    members.detect{|member| member.user_id == user.id }
  end

  ##
  # Check if an error with same message
  # and backtrace are already in this project. If there are
  # already an error with same data, create an ErrorEmbedded in
  # this error
  #
  # @params[String] the message
  # @params[Array] the backtrace
  # @return[Object] an Error or ErrorEmbedded
  #
  def error_with_message_and_backtrace(message, backtrace)
    error = error_reports.first(:message => message,
                        :backtrace => backtrace,
                        :project_id => self.id)
    unless error
      error_reports.build(:message => message,
                          :backtrace => backtrace)
    else
      error.same_errors.build
    end
  end

  ##
  # Search in _keyworks and if resolved or not
  #
  # @params[Array] the conditions with key :resolved, :search, :page, :per_page
  # @return[Array] the result paginate
  #
  def paginate_errors_with_search(params)
    error_search = {}
    if params.key?(:resolved)
      error_search[:resolved] = true  if params[:resolved] == 'y'
      error_search[:resolved] = false  if params[:resolved] == 'n'
    end
    error_search[:_keywords] = {'$in' => params[:search].split(' ').map(&:strip)} unless params[:search].blank?
    desc = params[:asc_order] || -1
    sorting = []
    if params.key?(:sort_by) && ['nb_comments', 'count'].include?(params[:sort_by])
      sorting << [params[:sort_by], desc]
      desc = -1 # the order by raised_at will then by descending
    end
    sorting << ['last_raised_at', desc.to_i]
    error_reports.paginate(:conditions => error_search,
             :page => params[:page] || 1,
             :per_page => params[:per_page] || 10,
             :sort => sorting)
  end

  # ClassMethod
  class << self
    def access_by(user)
      Project.all('members.user_id' => user.id)
    end

    def with_digest_request
      Project.all('members.notify_by_digest' => true)
    end
  end

  def gen_api_key!
    gen_api_key
    save
  end

  def gen_api_key
    self.api_key = SecureRandom.hex(12)
  end

  private

  def need_members
    errors.add(:members, 'need_member') if members.empty?
  end

  def need_admin_members
    errors.add(:members, 'need_admin_member') unless members.any?{ |m| m.admin }
  end

  def update_members_data
    members.each do |member|
      member.update_data
    end
  end
end
