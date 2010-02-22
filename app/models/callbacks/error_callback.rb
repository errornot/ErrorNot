module Callbacks::ErrorCallback
  ##
  # Extract a list of keywords for msg + comments.text of
  # the error
  # Put it in error._keywords
  # We call mongo-ruby-driver directly to avoid callback
  #
  def update_keywords
    update_keywords_task
  end



  ##
  # Check the youngest Time when a Error is raised and update data
  # last_raised_at in object.
  #
  # We call mongo-ruby-driver directly to avoid callback
  #
  def update_last_raised_at
    update_last_raised_at_task
  end
  def send_notify
    send_notify_task
  end

  ##
  # Call the method in project to update
  # number of errors define into it
  #
  def update_nb_errors_in_project
    Project.find(project_id).update_nb_errors
  end
end
