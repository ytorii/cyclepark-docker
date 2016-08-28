# Model for customer's leaf
class Leaf < ActiveRecord::Base
  has_one :customer, dependent: :destroy
  has_many :contracts, dependent: :destroy

  # This parametor is needed to use multiple models in the same form.
  accepts_nested_attributes_for :customer
  accepts_nested_attributes_for :contracts

  date_format = %r(\A20[0-9]{2}(/|-)(0[1-9]|1[0-2])(/|-)(0[1-9]|(1|2)[0-9]|3[01])\z)

  validates :number,
            presence: true,
            numericality: {
              greater_than: 0, less_than: 1057, allow_blank: true
            }
  validates :vhiecle_type,
            presence: true,
            numericality: {
              greater_than: 0, less_than: 10, allow_blank: true
            }
  validates :student_flag,
            inclusion: { in: [true, false] }
  validates :largebike_flag,
            inclusion: { in: [true, false] }
  validates :valid_flag,
            inclusion: { in: [true, false] }
  validates :start_date,
            presence: true,
            format: { with: date_format, allow_blank: true }
  validates :last_date,
            format: { with: date_format, unless: 'last_date.blank?' }
  validate :number_exists?, on: :create

  before_destroy :invalid_leaf?

  private

  def number_exists?
    if Leaf.where('number = ? and vhiecle_type = ? and valid_flag = ?',
                  number, vhiecle_type, true).exists?
      errors.add(:number, '指定された番号は既に使用されています。')
      return false
    end
  end

  # Only the invalid leaf is allowed to be deleted!
  def invalid_leaf?
    if valid_flag
      errors.add(:valid_flag, '契約中のリーフは削除できません。')
      return false
    end
  end
end
