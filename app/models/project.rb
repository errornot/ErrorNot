class Project
  include MongoMapper::Document

  key :name, String, :required => true

  has_many :error_reports, :class_name => 'Error'
end
