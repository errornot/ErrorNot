class Error
  include MongoMapper::Document

  key :resolved, Boolean, :index => true
  key :session, Hash
  key :raised_at, Time, :required => true
  key :backtrace, Array
  key :request, Hash
  key :environment, Hash
  key :data, Hash

  key :message, String, :required => true

  # Denormalisation
  key :_keywords, Array, :index => true
  key :last_raised_at, Time

  key :project_id, ObjectId, :required => true, :index => true
  belongs_to :project

  has_many :comments
  include_errors_from :comments

  has_many :same_errors, :class_name => 'ErrorEmbedded'
  include_errors_from :same_errors

  ## Callback
  before_save :update_comments
  before_save :reactive_if_new_error

  after_save :update_nb_errors_in_project
  after_save :update_keywords
  after_save :update_last_raised_at

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
    send_notify if !resolved? && new_same_error?
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

  ##
  # Extract a list of keywords for msg + comments.text of
  # the error
  # Put it in error._keywords
  # We call mongo-ruby-driver directly to avoid callback
  #
  def update_keywords
    words = (message.split(/[^\w]|[_]/) | comments.map(&:extract_words)).flatten
    self._keywords = words.delete_if(&:empty?).uniq
    # We made update direct to avoid some all callback recall
    collection.update({:_id => self._id}, {'$set' => {:_keywords => self._keywords}})
  end

  ##
  # Check the youngest Time when a Error is raised and update data
  # last_raised_at in object.
  #
  # We call mongo-ruby-driver directly to avoid callback
  #
  def update_last_raised_at
    last_raised_at = same_errors.empty? ? raised_at : same_errors.sort_by(&:raised_at).last.raised_at
    collection.update({:_id => self._id}, {'$set' => {:last_raised_at => last_raised_at.utc}})
  end

end
