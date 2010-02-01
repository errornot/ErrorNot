class MLogger
  include MongoMapper::Document

  key :resolved, Boolean
  key :session, Hash
  key :raised_at, DateTime # required
  key :backtrace, Hash
  key :request, Hash
  key :environment, Hash
  key :data, Hash

  key :message, String

  key :project_id, ObjectId
  belongs_to :project

  validates_presence_of :project_id
  validates_presence_of :message

end
