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

  ## Callback
  after_save :update_nb_errors_in_project

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


end
