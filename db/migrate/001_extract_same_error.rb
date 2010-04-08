ActionMailer::Base.delivery_method = :test
puts 'extract error_embedded from error collection'
Error.collection.find.each do |er|
  if er['same_errors']
    errors = []
    er['same_errors'].each do |same_error|
      errors << ErrorEmbedded.new(:error_id => er['_id'],
                           :session => same_error['session'],
                           :raised_at => same_error['raised_at'],
                           :request => same_error['request'],
                           :environment => same_error['environment'],
                           :data => same_error['data'])
    end
    er.delete('same_errors')
    Error.collection.update({'_id' => er['_id']}, er)
    errors.map(&:save!)
  end
end
