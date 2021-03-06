# Model for cyclepark staff
class Staff < ActiveRecord::Base
  has_one :staffdetail, dependent: :destroy

  # This parametor is needed to use multiple models in the same form.
  accepts_nested_attributes_for :staffdetail

  validates :nickname,
            presence: true,
            uniqueness: { allow_blank: true }, 
            length: { maximum: 10, allow_blank: true }
  validates :password,
            presence: true,
            format: { with: /\A[a-zA-Z0-9]+\z/, allow_blank: true },
            length: { minimum: 8, maximum: 16, allow_blank: true }
  validates :admin_flag,
            inclusion: { in: [true, false] }

  # Authentication with nickname and password.
  # Compares entered password with stored password by digesting with salt.
  class << self
    def authenticate(nickname, password)
      staff = find_by(nickname: nickname)

      staff if staff.try(:password) && correct_password?(staff, password)
    end

    private

    def correct_password?(staff, password)
      Digest::SHA1.hexdigest(staff.salt + password) == staff.password
    end
  end

  # Create digested password with salt before save.
  # Do not use after_validation because
  # that executes follow process even though invalid inputs!
  before_save do
    # Create a SALT value from SecureRandom module.
    self.salt = SecureRandom.hex(10).to_s
    # Create SHA1 digested password with salt.
    self.password = Digest::SHA1.hexdigest(salt + self.password)
  end
end
