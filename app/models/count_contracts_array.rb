# Result Array of counting contracts
class CountContractsArray
  def present_counts_array(in_month)
    # The skipped contracts must not be included in counts.
    present_contracts_count = Leaf.joins(contracts: :seals)
                                  .where("contracts.skip_flag = 'f'
                                 and seals.month = ?", in_month)
                                  .group(:vhiecle_type,
                                         :student_flag,
                                         :largebike_flag)
                                  .count

    calc_count_array(present_contracts_count)
  end

  def new_counts_array(in_month)
    # New contracts' start_month is requested month.
    # It's NOT seal's month!
    new_contracts_count = Leaf.joins(:contracts)
                              .where("contracts.new_flag = 't' and
                                     contracts.start_month = ?", in_month)
                              .group(:vhiecle_type,
                                     :student_flag,
                                     :largebike_flag)
                              .count

    calc_count_array(new_contracts_count)
  end

  private

  # Convert grouped count hash from DB to count array including total
  def calc_count_array(in_counts)
    [first_normal_count(in_counts),
     first_student_count(in_counts),
     first_total_count(in_counts),
     bike_normal_count(in_counts),
     bike_large_count(in_counts),
     bike_total_count(in_counts),
     second_count(in_counts)]
  end

  # SQL results are grouped by 3 columns and can be selected by them.
  def first_normal_count(in_counts)
    in_counts[[1, false, false]].to_i
  end

  def first_student_count(in_counts)
    in_counts[[1, true, false]].to_i
  end

  def first_total_count(in_counts)
    in_counts[[1, false, false]].to_i + in_counts[[1, true, false]].to_i
  end

  def bike_normal_count(in_counts)
    in_counts[[2, false, false]].to_i
  end

  def bike_large_count(in_counts)
    in_counts[[2, false, true]].to_i
  end

  def bike_total_count(in_counts)
    in_counts[[2, false, false]].to_i + in_counts[[2, false, true]].to_i
  end

  def second_count(in_counts)
    in_counts[[3, false, false]].to_i
  end
end
