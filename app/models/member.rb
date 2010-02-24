class Member
  include MongoMapper::EmbeddedDocument

  key :admin, Boolean
  key :notify_by_email, Boolean, :default => true
  key :notify_removal_by_email, Boolean, :default => true
  key :notify_by_digest, Boolean, :default => false
  key :digest_send_at, Time
  key :email, String
  key :status, Integer, :default => 0

  AWAITING = 0
  UNVALIDATE = 1
  VALIDATE = 2

  key :user_id, ObjectId
  belongs_to :user

  validates_presence_of :user_id, :if => Proc.new { email.blank? }

  def update_data
    unless user_id
      self.status = AWAITING
    else
      if user.confirmed?
        self.status = VALIDATE
      else
        self.status = UNVALIDATE
      end
      self.email = user.email
    end
  end

  ##
  # Update digest_send_at if needed
  #
  def notify_by_digest=(notify)
    write_attribute(:notify_by_digest, notify)
    self.digest_send_at = Time.now if notify && !self.digest_send_at
    self.digest_send_at = nil unless notify
  end

  ##
  # Send a digest about all error not already send by digest
  # from project where this member is
  def send_digest
    return unless notify_by_digest
    errors = self._root_document.error_reports.not_send_by_digest_since(self.digest_send_at)
    UserMailer.deliver_error_digest_notify(self.email, errors) unless errors.empty?
    self.digest_send_at = Time.now.utc
    self.save
    true
  end

end
