class LeafsSearchValidator
  include ActiveModel::Model

  attr_accessor :vhiecle_type_eq
  attr_accessor :number_eq
  attr_accessor :valid_flag_eq
  attr_accessor :customer_first_name_or_customer_last_name_cont

  validates :vhiecle_type_eq, 
    presence: { if: :is_number_search? },
    numericality: { greater_than: 0, less_than: 10, allow_blank: true }
  validates :number_eq, 
    presence: { if: :is_number_search? },
    numericality: { greater_than: 0, less_than: 1013, allow_blank: true }
  validates :valid_flag_eq, 
    presence: { if: :is_number_search? }
  validates :customer_first_name_or_customer_last_name_cont, 
    presence: { if: :is_name_search? }

  # When number query exists, number search is executed
  # even though name input is present!
  def is_number_search?
    number_eq.present? || vhiecle_type_eq.present? || valid_flag_eq.present?
  end

  def is_name_search?
    number_eq.blank? && vhiecle_type_eq.blank? && valid_flag_eq.blank?
  end

end