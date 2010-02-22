class Error
  include MongoMapper::Document
  include Callbacks::ErrorCallback

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

  # To keep track of some metrics:
  key :nb_comments, Integer, :required => true, :default => 0
  key :count, Integer, :required => true, :default => 1 # nb of same errors

  ## Callback
  before_save :update_comments
  before_save :update_count
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


  ##
  # code to update keywords
  # Not call in direct
  def update_keywords_task
    words = (self.message.split(/[^\w]|[_]/) | self.comments.map(&:extract_words)).flatten
    self._keywords = words.delete_if(&:empty?).uniq
    # We made update direct to avoid some all callback recall
    Error.collection.update({:_id => self.id}, {'$set' => {:_keywords => self._keywords}})
  end

  def update_comments
    self.nb_comments = comments.length
    comments.each do |comment|
      comment.update_informations
    end
  end

  def update_count
    self.count = 1 + same_errors.length
  end

  def send_notify
    project.members.each do |member|

  ##
  # Call by update_last_raised_at
  def update_last_raised_at_task
    last_raised_at = same_errors.empty? ? raised_at : same_errors.sort_by(&:raised_at).last.raised_at
    Error.collection.update({:_id => _id}, {'$set' => {:last_raised_at => last_raised_at.utc}})
  end

  ##
  # Call by send_notify
  def send_notify_task
    Project.find(project_id).members.each do |member|
      if member.notify_by_email?
        UserMailer.deliver_error_notify(member.email, self)
      end
    end
  end

  private

  def update_comments
    comments.each do |comment|
      comment.update_informations
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



end
