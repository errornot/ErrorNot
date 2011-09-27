class ErrorEmbedded
  include MongoMapper::EmbeddedDocument

  key :session, Hash
  key :raised_at, Time, :required => true
  key :request, Hash
  key :environment, Hash
  key :data, Hash
  key :error_id, ObjectId

  alias_method :root_error, :_parent_document

  delegate :last_raised_at, :to => :root_error
  delegate :same_errors, :to => :root_error
  delegate :project, :to => :root_error
  delegate :comments, :to => :root_error
  delegate :resolved, :to => :root_error
  delegate :message, :to => :root_error
  delegate :backtrace, :to => :root_error
  delegate :count, :to => :root_error

  after_save :reactive_error
  after_save :update_last_raised_at

  def url
    request['url']
  end

  def params
    request['params']
  end

  private

  def reactive_error
    if root_error.resolved
      root_error.resolved = false
      root_error.send_notify unless new?
      root_error.save!
    end
  end

  ##
  # Call by update_last_raised_at
  def update_last_raised_at
    if root_error.last_raised_at.utc < raised_at.utc
      root_error.last_raised_at = raised_at
      root_error.save
    end
  end

end