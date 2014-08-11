status :published
satisfies_need "100147"

## Q0
multiple_choice :are_you_paying_or_receiving? do
  option :pay
  option :receive

  save_input_as :paying_or_receiving

  calculate :fees_title do
    PhraseList.new(:"#{paying_or_receiving}_title")
  end

  calculate :collect_and_pay_service do
      PhraseList.new(:"#{paying_or_receiving}_collect_and_pay_service")
    end

  calculate :enforcement_charge do
    if responses.last == "pay"
      PhraseList.new(:enforcement_charge)
    end
  end

  next_node :how_many_children_paid_for?
end

## Q1
multiple_choice :how_many_children_paid_for? do
  option "1_child"
  option "2_children"
  option "3_children"

  precalculate :paying_or_receiving_text do
    paying_or_receiving == "pay" ? "paying" : "receiving"
  end

  precalculate :paying_or_receiving_hint do
    PhraseList.new(:"#{paying_or_receiving}_hint")
  end

  calculate :number_of_children do
    ## to_i will look for the first integer in the string
    responses.last.to_i
  end

  next_node :gets_benefits?
end

## Q2
multiple_choice :gets_benefits? do
  save_input_as :benefits
  option "yes"
  option "no"

  precalculate :benefits_title do
    PhraseList.new(:"#{paying_or_receiving}_benefits")
  end

  calculate :calculator do
    Calculators::ChildMaintenanceCalculator.new(number_of_children, benefits, paying_or_receiving)
  end

  next_node_if(:how_many_nights_children_stay_with_payee?, responded_with('yes'))
  next_node :gross_income_of_payee?
end

## Q3
money_question :gross_income_of_payee? do

  precalculate :income_title do
    PhraseList.new(:"#{paying_or_receiving}_income")
  end

  next_node_calculation :rate_type do |response|
    calculator.income = response
    calculator.rate_type
  end

  next_node_if(:nil_rate_result) { rate_type == :nil }
  next_node_if(:flat_rate_result) { rate_type == :flat }
  next_node :how_many_other_children_in_payees_household?
end

## Q4
value_question :how_many_other_children_in_payees_household? do

  precalculate :number_of_children_title do
    PhraseList.new(:"#{paying_or_receiving}_number_of_children")
  end

  calculate :calculator do
    # if converting to int messes things up, raise invalid response
    # this deals with nil input through the API
    raise SmartAnswer::InvalidResponse if responses.last.to_i.to_s != responses.last
    calculator.number_of_other_children = responses.last.to_i
    calculator
  end
  next_node :how_many_nights_children_stay_with_payee?
end

## Q5
multiple_choice :how_many_nights_children_stay_with_payee? do
  option 0
  option 1
  option 2
  option 3
  option 4

  precalculate :how_many_nights_title do
    PhraseList.new(:"#{paying_or_receiving}_how_many_nights")
  end

  calculate :child_maintenance_payment do
    calculator.number_of_shared_care_nights = responses.last.to_i
    sprintf("%.0f", calculator.calculate_maintenance_payment)
  end

  next_node_calculation :rate_type do |response|
    calculator.number_of_shared_care_nights = response.to_i
    calculator.rate_type
  end

  next_node_if(:nil_rate_result) { rate_type == :nil }
  next_node_if(:flat_rate_result) { rate_type == :flat }
  next_node :reduced_and_basic_rates_result
end

outcome :nil_rate_result do
  precalculate :nil_rate_reason do
    if benefits == 'yes'
      PhraseList.new(:nil_rate_reason_benefits)
    else
      PhraseList.new(:nil_rate_reason_income)
    end
  end
end

outcome :flat_rate_result do
  precalculate :flat_rate_amount do
    sprintf('%.2f', calculator.base_amount)
  end
  precalculate :collect_fees do
    sprintf('%.2f', calculator.collect_fees)
  end
  precalculate :total_fees do
    sprintf('%.2f', calculator.total_fees(flat_rate_amount, collect_fees))
  end
  precalculate :total_yearly_fees do
    sprintf('%.2f', calculator.total_yearly_fees(collect_fees))
  end
end

outcome :reduced_and_basic_rates_result do
  precalculate :rate_type_formatted do
    rate_type = calculator.rate_type
    if rate_type.to_s == 'basic_plus'
      'basic plus'
    else
      rate_type.to_s
    end
  end
  precalculate :child_maintenance_payment do
    sprintf('%.2f', child_maintenance_payment)
  end
  precalculate :collect_fees do
    sprintf('%.2f', calculator.collect_fees_cmp(child_maintenance_payment))
  end
  precalculate :total_fees do
    sprintf('%.2f', calculator.total_fees_cmp(child_maintenance_payment, collect_fees))
  end
  precalculate :total_yearly_fees do
    sprintf('%.2f', calculator.total_yearly_fees(collect_fees))
  end

end
