# Models to count the number of customer's for statistics.
class CountContractsSummary
  include ActiveModel::Model

  attr_accessor :month

  date_format =
    %r(\A20[0-9]{2}(/|-)(0[1-9]|1[0-2])(/|-)(0[1-9]|(1|2)[0-9]|3[01])\z)

  validates :month, format: { with: date_format }

  def initialize(in_month)
    @month = in_month.presence || Date.current
    @countContractsArray = CountContractsArray.new(@month)
  end

  def count_contracts_summary
    count_array = @countContractsArray.count_contracts_array

    {
      'present_total' => count_array[2],
      'present_new' => count_array[3],
      'next_total' => count_array[4],
      'next_new' => count_array[5],
      'diffs_prev' => diff_array(count_array[2], count_array[0]),
      'next_unpaid' =>
      unpaid_array(count_array[2], count_array[4], count_array[5])
    }

  end

  private

  # Diffs from prev_month = this_month - prev_month
  def diff_array(ary1, ary2)
    [ary1, ary2].transpose.map { |f, s| f - s }
  end

  # Next_unpaid = present_total - (next_total - next_new)
  # This value should'nt be smaller than 0, and first and bike's
  # total count should be calculated again to avoid unmatched values.
  def unpaid_array(ary1, ary2, ary3)
    [ary1, ary2, ary3]
      .transpose
      .map { |f, s, t| (f - s + t) >= 0 ? f - s + t : 0 }
      .tap do |array|
      array[2] = array[0] + array[1]
      array[5] = array[3] + array[4]
    end
  end
end
