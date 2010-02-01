class Project
  include MongoMapper::Document

  key :name, String

  validates_presence_of :name
end
