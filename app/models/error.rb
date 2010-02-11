class Error
  include MongoMapper::Document

  key :resolved, Boolean
  key :session, Hash
  key :raised_at, DateTime, :required => true
  key :backtrace, Array
  key :request, Hash
  key :environment, Hash
  key :data, Hash

  key :message, String, :required => true

  key :project_id, ObjectId, :required => true
  belongs_to :project

  has_many :comments
  include_errors_from :comments

  has_many :same_errors, :class_name => 'ErrorEmbedded'
  include_errors_from :same_errors

  ## Callback
  after_save :update_nb_errors_in_project
  before_save :update_comments
  before_save :reactive_if_new_error

  after_create :send_notify
  after_update :resend_notify

  timestamps!

  def url
    request['url']
  end

  def params
    request['params']
  end

  def resolved!
    self.resolved = true
    save!
  end

  private

  ##
  # Call the method in project to update
  # number of errors define into it
  #
  def update_nb_errors_in_project
    project.update_nb_errors
  end

  def update_comments
    comments.each do |comment|
      comment.update_informations
    end
  end

  def send_notify
    project.members.each do |member|
      if member.notify_by_email?
        UserMailer.deliver_error_notify(member.email, self)
      end
    end
  end

  def resend_notify
    if !resolved? && new_same_error?
      send_notify
    end
  end

  ##
  # Mark error like un_resolved if a new error is add
  # An new error is arrived if embedded has no id ( little hack )
  #
  def reactive_if_new_error
    self.resolved = false if new_same_error?
  end

  # Check if new error embedded
  def new_same_error?
    same_errors.any?{|error| error.id.nil? }
  end
end
