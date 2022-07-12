module SmartAnswer::Calculators
  class CheckFireSafetyCostsCalculator
    include ActionView::Helpers::NumberHelper

    attr_accessor :purchased_pre_or_post_february_2022,
                  :year_of_purchase,
                  :value_of_property,
                  :live_in_london,
                  :shared_ownership,
                  :percentage_owned,
                  :amount_already_paid

    FIRST_VALID_YEAR = 1900
    LAST_VALID_YEAR = 2022
    MIN_PERCENTAGE_LIMIT = 0.1
    MAX_PERCENTAGE_LIMIT = 1
    OUTSIDE_LONDON_VALUATION_LIMIT = 175_000
    INSIDE_LONDON_VALUATION_LIMIT = 325_000
    ONE_MILLION = 1_000_000
    TWO_MILLION = 2_000_000
    TEN_THOUSAND = 10_000
    FIFTEEN_THOUSAND = 15_000
    FIFTY_THOUSAND = 50_000
    ONE_HUNDRED_THOUSAND = 100_000
    ANNUAL_COST_OFFSET = 10

    def purchased_before_feb_2022?
      @purchased_pre_or_post_february_2022 == "pre_feb_2022"
    end

    def valid_percentage_owned?
      @percentage_owned.between?(MIN_PERCENTAGE_LIMIT, MAX_PERCENTAGE_LIMIT)
    end

    def property_uprating_values
      @property_uprating_values ||= YAML.load_file(Rails.root.join("config/smart_answers/check_fire_safety_costs_data.yml")).freeze
    end

    def uprated_value_of_property
      (property_uprating_values.fetch(@year_of_purchase, default_uprating_value) * @value_of_property.to_f).ceil
    end

    def fully_protected_from_costs?
      under_valuation_limit_living_inside_london || under_valuation_limit_living_outside_london
    end

    def presented_leaseholder_costs
      @presented_leaseholder_costs ||= cost_as_currency(leaseholder_costs)
    end

    def presented_annual_leaseholder_costs
      @presented_annual_leaseholder_costs ||= cost_as_currency(annual_leaseholder_costs)
    end

    def presented_remaining_costs
      @presented_remaining_costs ||= cost_as_currency(remaining_costs)
    end

    def remaining_costs_more_than_annual_leaseholder_costs?
      remaining_costs.to_f > annual_leaseholder_costs
    end

    def remaining_costs_less_than_annual_leaseholder_costs?
      remaining_costs.to_f <= annual_leaseholder_costs
    end

    def fully_repaid?
      remaining_costs <= 0
    end

  private

    def default_uprating_value
      property_uprating_values["default"]
    end

    def under_valuation_limit_living_inside_london
      uprated_value_of_property <= OUTSIDE_LONDON_VALUATION_LIMIT && live_in_london == "no"
    end

    def under_valuation_limit_living_outside_london
      uprated_value_of_property <= INSIDE_LONDON_VALUATION_LIMIT && live_in_london == "yes"
    end

    def leaseholder_costs
      @leaseholder_costs ||= if uprated_value_of_property.between?(OUTSIDE_LONDON_VALUATION_LIMIT, ONE_MILLION) && live_in_london == "no"
                               shared_ownership_costs(TEN_THOUSAND)
                             elsif uprated_value_of_property.between?(INSIDE_LONDON_VALUATION_LIMIT, ONE_MILLION) && live_in_london == "yes"
                               shared_ownership_costs(FIFTEEN_THOUSAND)
                             elsif uprated_value_of_property >= TWO_MILLION
                               shared_ownership_costs(ONE_HUNDRED_THOUSAND)
                             elsif uprated_value_of_property >= ONE_MILLION
                               shared_ownership_costs(FIFTY_THOUSAND)
                             end
    end

    def shared_ownership_costs(basic_cost)
      @shared_ownership == "yes" ? @percentage_owned * basic_cost : basic_cost
    end

    def annual_leaseholder_costs
      leaseholder_costs / ANNUAL_COST_OFFSET
    end

    def remaining_costs
      (leaseholder_costs - @amount_already_paid.to_f).ceil
    end

    def cost_as_currency(costs)
      number_to_currency(costs, unit: "£", precision: 0)
    end
  end
end
