class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :email, :first_name, :last_name, :presence => true

  def should_validate_password?
    (!password.blank? && !password_confirmation.blank?) || new_record?
  end

  def password_required?
    (!password.blank? && !password_confirmation.blank?) || new_record?
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
