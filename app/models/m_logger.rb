class MLogger
  include MongoMapper::Document

  key :application, String
  key :composant, String
  key :message, Integer
  key :information, Hash

  validates_presence_of :application
end
