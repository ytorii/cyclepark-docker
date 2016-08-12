require 'nkf'

class Customer < ActiveRecord::Base
  belongs_to :leaf

  read_format = /\A[\p{Katakana}\u30fc\p{blank}]+\z/

  validates :first_name,
    presence: true,
    length: { maximum: 10, allow_blank: true }
  validates :last_name,
    presence: true,
    length: { maximum: 10, allow_blank: true }
  validates :first_read,
    format: { with: read_format, allow_blank: true },
    length: { maximum: 20, allow_blank: true }
  validates :last_read,
    format: { with: read_format, allow_blank: true },
    length: { maximum: 20, allow_blank: true }
  validates :sex,
    inclusion: {in: [true, false]}
  validates :address,
    presence: true,
    length: { maximum: 50, allow_blank: true }
  validates :phone_number,
    presence: { if: 'cell_number.blank?' },
    format: { with: /\A([0-9]|-)+\z/, allow_blank: true },
    length: { maximum: 12, allow_blank: true}
  validates :cell_number,
    presence: { if: 'phone_number.blank?', allow_blank: true },
    format: { with: /\A[0-9]{3}-[0-9]{4}-[0-9]{4}\z/, allow_blank: true}
  validates :receipt,
    presence: true,
    length: { maximum: 50 }
  validates :comment,
    length: { maximum: 100 }

  before_validation do
    self.first_read = NKF.nkf('-wh2', first_read) if first_read
    self.last_read = NKF.nkf('-wh2', last_read) if last_read
  end
end
