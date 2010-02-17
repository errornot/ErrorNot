class ErrorEmbedded
  include MongoMapper::EmbeddedDocument

  key :session, Hash
  key :raised_at, Time, :required => true
  key :request, Hash
  key :environment, Hash
  key :data, Hash

end
