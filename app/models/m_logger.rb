class MLogger
  include MongoMapper::Document

  key :application, String
  key :composant, String
  key :message, String
  key :information, Hash
  key :severity, Integer

  CRITICAL = 0
  ERROR = 1
  WARNING = 2
  NOTICE = 3
  INFO = 4
  DEBUG = 5

  validates_presence_of :application
  validates_presence_of :composant
  validates_presence_of :message
  validates_presence_of :severity
  
  validates_format_of :severity, :with => /^[012345]$/


end
