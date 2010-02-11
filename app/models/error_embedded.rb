class ErrorEmbedded
  include MongoMapper::EmbeddedDocument

  key :session, Hash
  key :raised_at, DateTime, :required => true
  key :request, Hash
  key :environment, Hash
  key :data, Hash

end
