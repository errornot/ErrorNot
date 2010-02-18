class ErrorEmbedded
  include MongoMapper::EmbeddedDocument

  key :session, Hash
  key :raised_at, Time, :required => true
  key :request, Hash
  key :environment, Hash
  key :data, Hash

  delegate :last_raised_at, :to => :_root_document
  delegate :same_errors, :to => :_root_document
  delegate :project, :to => :_root_document
  delegate :comments, :to => :_root_document

  def url
    request['url']
  end

  def params
    request['params']
  end

end
