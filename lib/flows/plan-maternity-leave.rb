status :draft
satisfies_need "855"

date_question :baby_due_date? do 
	save_input_as :due_date

	next_node :leave_start?
end

date_question :leave_start? do
	calculate :start_date do
    start_date = Date.parse(responses.last)
    due_date_p = Date.parse(due_date)
    raise SmartAnswer::InvalidResponse if start_date > due_date_p or start_date < 11.weeks.ago(due_date_p) 
    responses.last
  end

  calculate :calculator do
    Calculators::PlanMaternityLeave.new(due_date: due_date, start_date: start_date)
  end

	next_node :maternity_leave_details
end

outcome :maternity_leave_details do
	precalculate :due_date_formatted do
		calculator.formatted_due_date
	end
  precalculate :start_date_formatted do
  	calculator.formatted_start_date
  end
  precalculate :distance_start do
    calculator.distance_start
  end
  precalculate :qualifying_week do
    calculator.qualifying_week.last
  end
  precalculate :earliest_start do
    calculator.earliest_start
  end
  precalculate :period_of_ordinary_leave do
    calculator.format_date_range calculator.period_of_ordinary_leave
  end
  precalculate :period_of_additional_leave do
    calculator.format_date_range calculator.period_of_additional_leave
  end
end