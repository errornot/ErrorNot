class User

  include MongoMapper::Document

  ## Include default devise modules.
  ## Others available are :lockable, :timeoutable and :activatable.
  devise :authenticatable, :confirmable, :recoverable, :rememberable, :trackable, :validatable

end
