module SmartAnswer::Calculators
  class MaternityPaternityCalculator
  
    attr_reader :expected_week, :qualifying_week, :employment_start, :notice_of_leave_deadline, 
      :leave_earliest_start_date, :proof_of_pregnancy_date, :relevant_period, :adoption_placement_date
    
    attr_accessor :employment_contract, :leave_start_date, :average_weekly_earnings
    
    LOWER_EARNING_LIMITS = { 2011 => 102, 2012 => 107 }
    MATERNITY_RATE = PATERNITY_RATE = 135.45

    def initialize(match_or_due_date)
      @due_date = match_or_due_date
      expected_start = match_or_due_date - match_or_due_date.wday
      @expected_week = expected_start .. expected_start + 6.days
      @notice_of_leave_deadline = qualifying_start = 15.weeks.ago(expected_start)
      @qualifying_week = qualifying_start .. qualifying_start + 6.days
      @relevant_period = "#{8.weeks.ago(qualifying_start).to_s(:long)} and #{qualifying_start.to_s(:long)}"
      @employment_start = 26.weeks.ago(expected_start)
      @leave_earliest_start_date = 11.weeks.ago(match_or_due_date)
      @proof_of_pregnancy_date = 13.weeks.ago(match_or_due_date)
    end
    
    def leave_end_date
      52.weeks.since(@leave_start_date)
    end
    
    def pay_start_date
      @leave_start_date
    end
    
    def pay_end_date
      39.weeks.since(pay_start_date)
    end
    
    def statutory_maternity_rate
      (@average_weekly_earnings.to_f * 0.9).round(2)
    end
    
    def statutory_maternity_rate_a
      statutory_maternity_rate
    end
    
    def statutory_maternity_rate_b
      (MATERNITY_RATE < statutory_maternity_rate ? MATERNITY_RATE : statutory_maternity_rate)
    end
    
    def lower_earning_limit(year=Date.today.year)
      LOWER_EARNING_LIMITS[year]
    end
    
    def employment_end
      @due_date
    end
    
    def adoption_placement_date=(date)
      @adoption_placement_date = date
      @leave_earliest_start_date = 14.days.ago(date)
    end
    
    def adoption_leave_start_date=(date)
      @leave_start_date = date
    end

    ## Paternity
    ##
    ## Statutory paternity rate
    def statutory_paternity_rate
      awe = (@average_weekly_earnings.to_f * 0.9).round(2)
      (PATERNITY_RATE < awe ? PATERNITY_RATE : awe)
    end
    
    ## Adoption
    ##
    ## Statutory adoption rate
    def statutory_adoption_rate
      statutory_maternity_rate_b
    end
    
  end
end
