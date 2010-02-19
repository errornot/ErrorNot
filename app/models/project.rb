class Project
  include MongoMapper::Document

  key :api_key, String, :required => true, :index => true
  key :name, String, :required => true

  key :nb_errors_reported, Integer, :default => 0
  key :nb_errors_resolved, Integer, :default => 0
  key :nb_errors_unresolved, Integer, :default => 0

  has_many :error_reports, :class_name => 'Error'

  has_many :members

  validate :need_members
  validate :need_admin_members

  include_errors_from :members

  ## CALLBACK
  before_validation_on_create :gen_api_key
  before_save :update_members_data

  def add_admin_member(user)
    members.build(:user => user, :admin => true)
  end

  def member_include?(user)
    members.any?{|member| member.user_id == user.id}
  end

  def admin_member?(user)
    members.any?{|member| member.user_id == user.id && member.admin? }
  end

  def remove_member!(user)
    members.delete_if{|member| member.user_id.to_s == user.id.to_s && !member.admin? }
    save!
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
        UserMailer.deliver_project_invitation(email.strip, self)
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
    if params.key?(:resolved) && params[:resolved]
      error_search[:resolved] = (params[:resolved] == 'y')
    end
    error_search[:_keywords] = {'$in' => params[:search].split(' ').map(&:strip)} unless params[:search].blank?
    desc = params[:asc_order] || -1
    sorting = []
    if params.key?(:sort_by) && ['nb_comments', 'count'].include?(params[:sort_by])
      sorting << [params[:sort_by], desc]
      desc = -1 # the order by raised_at will then by descending
    end
    sorting << ['raised_at', desc]
    error_reports.paginate(:conditions => error_search,
             :page => params[:page] || 1,
             :per_page => params[:per_page] || 10,
             :sort => sorting)
  end

  class << self
    def access_by(user)
      Project.all('members.user_id' => user.id)
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
