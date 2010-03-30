puts 'extract error_embedded from error collection'
Error.collection.find.each do |er|
  if er['same_errors']
    er.delete('same_errors')
    Error.collection.update({'_id' => er['_id']}, er)
  end
end
