puts 'extract error_embedded from error collection'
Error.collection.find.each do |er|
  if er['same_errors']
    ErrorEmbedded.create!(:error_id => er['_id'],
                         :session => er['session'],
                         :raised_at => er['raised_at'],
                         :request => er['request'],
                         :environment => er['environment'],
                         :data => er['data'])
    er.delete('same_errors')
    Error.collection.update({'_id' => er['_id']}, er)
  end
end
