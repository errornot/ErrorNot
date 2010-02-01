class Error
  include MongoMapper::Document

  key :resolved, Boolean
  key :session, Hash
  key :raised_at, DateTime, :required => true
  key :backtrace, Hash
  key :request, Hash
  key :environment, Hash
  key :data, Hash

  key :message, String, :required => true

  key :project_id, ObjectId, :required => true
  belongs_to :project


end
