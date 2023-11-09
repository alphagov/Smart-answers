class CheckUkVisaFlow < SmartAnswer::Flow
  def define
    flow = self
    content_id "dc1a1744-4089-43b3-b2e3-4e397b6b15b1"
    name "check-uk-visa"
    status :published

    additional_countries = UkbaCountry.all

    # Q1
    country_select :what_passport_do_you_have?, additional_countries:, exclude_countries: SmartAnswer::Calculators::UkVisaCalculator::EXCLUDE_COUNTRIES do
      on_response do |response|
        self.calculator = SmartAnswer::Calculators::UkVisaCalculator.new
        calculator.passport_country = response
        self.purpose_of_visit_answer = nil
      end

      next_node do
        if calculator.passport_country_is_israel?
          question :israeli_document_type?
        elsif calculator.passport_country_is_estonia?
          question :what_sort_of_passport?
        elsif calculator.passport_country_is_latvia?
          question :what_sort_of_passport?
        elsif calculator.passport_country_is_hong_kong?
          question :what_sort_of_travel_document?
        elsif calculator.passport_country_is_macao?
          question :what_sort_of_travel_document?
        elsif calculator.passport_country_is_ireland?
          outcome :outcome_no_visa_needed_ireland
        else
          question :purpose_of_visit?
        end
      end
    end

    # Q1b
    radio :israeli_document_type? do
      option :"full-passport"
      option :"provisional-passport"

      on_response do |response|
        calculator.passport_country = "israel-provisional-passport" if response == "provisional-passport"
      end

      next_node do
        question :purpose_of_visit?
      end
    end

    # Q1c / Q1d
    radio :what_sort_of_passport? do
      option :citizen
      option :alien

      next_node do |response|
        if response == "alien"
          if calculator.passport_country_is_estonia?
            calculator.passport_country = "estonia-alien-passport"
          elsif calculator.passport_country_is_latvia?
            calculator.passport_country = "latvia-alien-passport"
          end
        end
        question :purpose_of_visit?
      end
    end

    # Q1e / Q1f
    radio :what_sort_of_travel_document? do
      option :passport
      option :travel_document

      on_response do |response|
        calculator.travel_document_type = response
      end

      next_node do |_|
        question :purpose_of_visit?
      end
    end

    # Q2
    radio :purpose_of_visit? do
      option :tourism
      option :work
      option :study
      option :transit
      option :family
      option :marriage
      option :school
      option :medical
      option :diplomatic

      flow.travel_response_next_route(self)
    end

    # Q2a
    radio :travelling_to_cta? do
      option :channel_islands_or_isle_of_man
      option :republic_of_ireland
      option :somewhere_else

      on_response do |response|
        calculator.travelling_to_cta_answer = response
      end

      next_node do
        if calculator.travelling_to_channel_islands_or_isle_of_man?
          next question :channel_islands_or_isle_of_man?
        elsif calculator.has_passport_requiring_no_visa?
          next outcome :outcome_no_visa_needed
        elsif calculator.travelling_to_ireland?
          next outcome :outcome_transit_to_the_republic_of_ireland
        elsif calculator.travelling_to_elsewhere?
          next question :passing_through_uk_border_control?
        end
      end
    end

    # Q2b
    radio :channel_islands_or_isle_of_man? do
      option :tourism
      option :work
      option :study
      option :family
      option :marriage
      option :school
      option :medical
      option :diplomatic

      flow.travel_response_next_route(self)
    end

    # Q3
    radio :passing_through_uk_border_control? do
      option :yes
      option :no

      on_response do |response|
        calculator.passing_through_uk_border_control_answer = response
      end

      next_node do
        if calculator.passing_through_uk_border_control? && calculator.passport_country_is_taiwan?
          outcome :outcome_transit_taiwan_through_border_control
        elsif calculator.passing_through_uk_border_control? && calculator.requires_a_visitor_in_transit_visa?
          outcome :outcome_transit_leaving_airport
        elsif calculator.passing_through_uk_border_control? && calculator.requires_a_direct_airside_transit_visa?
          outcome :outcome_transit_leaving_airport_direct_airside_transit_visa
        elsif calculator.passport_country_is_taiwan?
          outcome :outcome_transit_taiwan
        elsif calculator.passport_country_is_venezuela?
          outcome :outcome_no_visa_needed
        elsif calculator.applicant_is_stateless_or_a_refugee?
          outcome :outcome_transit_refugee_not_leaving_airport
        elsif calculator.requires_a_direct_airside_transit_visa?
          outcome :outcome_transit_not_leaving_airport
        elsif calculator.no_transit_visa_is_required?
          outcome :outcome_no_visa_needed
        end
      end
    end

    # Q4
    radio :staying_for_how_long? do
      option :six_months_or_less
      option :longer_than_six_months

      on_response do |response|
        calculator.length_of_stay = response
      end

      next_node do
        if calculator.work_visit? && calculator.staying_for_over_six_months?
          question :what_type_of_work?
        elsif calculator.work_visit?
          work_outcome = flow.work_visit_outcome_lambda.call calculator
          outcome work_outcome unless work_outcome.nil?
        elsif calculator.study_visit?
          study_outcome = flow.study_visit_lambda.call calculator
          outcome study_outcome unless study_outcome.nil?
        end
      end
    end

    # Q5
    radio :travelling_visiting_partner_family_member? do
      option :yes
      option :no

      next_node do |response|
        if response == "yes"
          outcome :outcome_tourism_visa_partner
        else
          outcome :outcome_standard_visitor_visa
        end
      end
    end

    # Q6
    radio :partner_family_british_citizen? do
      option :yes
      option :no

      next_node do |response|
        if response == "yes"
          outcome :outcome_partner_family_british_citizen_y
        else
          question :partner_family_eea?
        end
      end
    end

    # Q7
    radio :partner_family_eea? do
      option :yes
      option :no

      next_node do |response|
        if response == "yes"
          outcome :outcome_partner_family_eea_y
        else
          outcome :outcome_partner_family_eea_n
        end
      end
    end

    # Q8
    radio :what_type_of_work? do
      option :health
      option :digital
      option :academic
      option :arts
      option :sports
      option :religious
      option :business
      option :other

      next_node do |response|
        calculator.what_type_of_work = response
        outcome :outcome_work_y
      end
    end

    outcome :outcome_diplomatic_business
    outcome :outcome_joining_family_nvn
    outcome :outcome_marriage_nvn_british_overseas_territories
    outcome :outcome_marriage_taiwan
    outcome :outcome_marriage_visa_nat_direct_airside_transit_visa
    outcome :outcome_marriage_electronic_visa_waiver
    outcome :outcome_medical_n
    outcome :outcome_medical_y
    outcome :outcome_no_visa_needed
    outcome :outcome_no_visa_needed_ireland
    outcome :outcome_partner_family_british_citizen_y
    outcome :outcome_partner_family_eea_y
    outcome :outcome_partner_family_eea_n
    outcome :outcome_school_n
    outcome :outcome_school_waiver
    outcome :outcome_school_y
    outcome :outcome_standard_visitor_visa
    outcome :outcome_study_m
    outcome :outcome_study_waiver
    outcome :outcome_study_waiver_taiwan
    outcome :outcome_study_no_visa_needed
    outcome :outcome_study_y
    outcome :outcome_transit_leaving_airport
    outcome :outcome_transit_leaving_airport_direct_airside_transit_visa
    outcome :outcome_transit_not_leaving_airport
    outcome :outcome_transit_refugee_not_leaving_airport
    outcome :outcome_transit_taiwan
    outcome :outcome_transit_taiwan_through_border_control
    outcome :outcome_transit_to_the_republic_of_ireland
    outcome :outcome_tourism_n
    outcome :outcome_tourism_visa_partner
    outcome :outcome_visit_waiver
    outcome :outcome_visit_waiver_taiwan
    outcome :outcome_work_m
    outcome :outcome_work_n
    outcome :outcome_work_waiver
    outcome :outcome_work_y
  end

  def travel_response_next_route(node)
    node.on_response do |response|
      calculator.purpose_of_visit_answer = response
    end

    node.next_node do
      if calculator.study_visit? || calculator.work_visit?
        next question(:staying_for_how_long?)
      end

      if calculator.diplomatic_visit?
        next outcome(:outcome_diplomatic_business)
      end

      if calculator.school_visit?
        if calculator.has_passport_requiring_electronic_visa_waiver_list?
          next outcome(:outcome_school_waiver)
        elsif calculator.passport_country_is_taiwan?
          next outcome(:outcome_study_waiver_taiwan)
        elsif calculator.has_passport_allowing_school_visits?
          next outcome(:outcome_school_n)
        else
          next outcome(:outcome_school_y)
        end
      end

      if calculator.medical_visit?
        if calculator.has_passport_requiring_electronic_visa_waiver_list?
          next outcome(:outcome_visit_waiver)
        elsif calculator.passport_country_is_taiwan?
          next outcome(:outcome_visit_waiver_taiwan)
        elsif calculator.has_passport_requiring_no_visa?
          next outcome(:outcome_medical_n)
        else
          next outcome(:outcome_medical_y)
        end
      end

      if calculator.tourism_visit?
        if calculator.has_passport_requiring_electronic_visa_waiver_list?
          next outcome(:outcome_visit_waiver)
        elsif calculator.passport_country_is_taiwan?
          next outcome(:outcome_visit_waiver_taiwan)
        elsif calculator.has_passport_requiring_no_visa?
          next outcome(:outcome_tourism_n)
        else
          next question(:travelling_visiting_partner_family_member?)
        end
      end

      if calculator.marriage_visit?
        if calculator.passport_country_in_eea?
          next outcome(:outcome_marriage_nvn_british_overseas_territories)
        elsif calculator.passport_country_in_non_visa_national_list? || calculator.passport_country_in_british_overseas_territories_list?
          next outcome(:outcome_marriage_nvn_british_overseas_territories)
        elsif calculator.has_passport_requiring_electronic_visa_waiver_list?
          next outcome(:outcome_marriage_electronic_visa_waiver)
        elsif calculator.passport_country_is_taiwan?
          next outcome(:outcome_marriage_taiwan)
        elsif calculator.requires_a_direct_airside_transit_visa? || calculator.passport_country_in_visa_national_list?
          next outcome(:outcome_marriage_visa_nat_direct_airside_transit_visa)
        end
      end

      if calculator.transit_visit?
        next question(:travelling_to_cta?)
      end

      if calculator.family_visit?
        if calculator.passport_country_in_non_visa_national_list? || calculator.passport_country_in_eea? || calculator.passport_country_in_british_overseas_territories_list?
          next outcome(:outcome_joining_family_nvn)
        else
          next question(:partner_family_british_citizen?)
        end
      end
    end
  end

  def study_visit_lambda
    lambda { |calculator|
      if calculator.staying_for_over_six_months?
        return :outcome_study_y # outcome 2 study y
      elsif calculator.staying_for_six_months_or_less? && calculator.has_passport_requiring_electronic_visa_waiver_list?
        return :outcome_study_waiver
      elsif calculator.staying_for_six_months_or_less? && calculator.passport_country_is_taiwan?
        return :outcome_study_waiver_taiwan
      elsif calculator.staying_for_six_months_or_less? &&
          (calculator.requires_a_direct_airside_transit_visa? ||
          calculator.passport_country_in_visa_national_list? ||
          calculator.travel_document?)

        return :outcome_study_m # outcome 3 study m visa needed short courses
      elsif calculator.staying_for_six_months_or_less? &&
          (calculator.passport_country_in_british_overseas_territories_list? ||
          calculator.passport_country_in_non_visa_national_list? ||
          calculator.passport_country_in_eea?)

        return :outcome_study_no_visa_needed # outcome 1 no visa needed
      else
        return nil
      end
    }
  end

  def work_visit_outcome_lambda
    lambda { |calculator|
      if calculator.staying_for_six_months_or_less? && calculator.has_passport_requiring_electronic_visa_waiver_list?
        return :outcome_work_waiver
      elsif calculator.staying_for_six_months_or_less? && calculator.short_work_visits_are_approved?
        return :outcome_work_n # outcome 5.5 work N no visa needed
      elsif calculator.staying_for_six_months_or_less?
        return :outcome_work_m # outcome 5 work m visa needed short courses
      else
        return nil
      end
    }
  end
end
