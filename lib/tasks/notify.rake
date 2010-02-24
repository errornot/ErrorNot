namespace :notify do

  desc 'send all request of digest'
  task :digest => [:environment] do
    Project.with_digest_request.each do |project|
      project.members.each do |member|
        member.send_digest
      end
    end
  end
end
