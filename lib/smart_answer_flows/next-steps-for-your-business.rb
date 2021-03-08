# ======================================================================
# The flow logic.
# ======================================================================

module SmartAnswer
  class NextStepsForYourBusinessFlow < Flow
    def define
      name "next-steps-for-your-business"
      start_page_content_id "4d7751b5-d860-4812-aa36-5b8c57253ff2"
      flow_content_id "981e0708-9fa5-42fb-baf5-ee5630a9b722"
      status :draft
      use_session true
      # ======================================================================
      # Available input types:
      # ======================================================================
      # - Checkbox
      # - Country select
      # - Date
      # - Money
      # - Radio
      # - Postcode
      # - Salary
      # - Value (text)

      # ======================================================================
      # What is your company registration number?
      # ======================================================================
      value_question :crn? do
        on_response do |response|
          self.calculator = Calculators::NextStepsForYourBusinessCalculator.new
          calculator.crn = response
        end

        next_node do
          question :annual_turnover?
        end
      end

      # ======================================================================
      # Will your business take more than £85,000 in a 12 month period?
      # ======================================================================
      radio :annual_turnover? do
        option :more_than_85k
        option :less_than_85k
        option :maybe_85k

        on_response do |response|
          calculator.annual_turnover = response
        end

        next_node do
          question :employ_someone?
        end
      end

      # ======================================================================
      # Do you want to employ someone?
      # ======================================================================
      radio :employ_someone? do
        option :will_employ
        option :already_employ
        option :no_employ
        option :maybe_employ

        on_response do |response|
          calculator.employ_someone = response
        end

        next_node do
          question :business_intent?
        end
      end

      # ======================================================================
      # Does your business do any of the following?
      # ======================================================================
      checkbox_question :business_intent? do
        option :buy_abroad
        option :sell_abroad
        option :sell_online
        none_option

        on_response do |response|
          calculator.business_intent = response.split(",")
        end

        next_node do
          question :business_support?
        end
      end

      # ======================================================================
      # Are you looking for financial support for:
      # ======================================================================
      checkbox_question :business_support? do
        option :started_finance
        option :growing_finance
        option :covid_finance
        none_option

        on_response do |response|
          calculator.business_support = response.split(",")
        end

        next_node do
          question :business_premises?
        end
      end

      # ======================================================================
      # Where are you running your business?
      # ======================================================================
      radio :business_premises? do
        option :location_home
        option :location_renting
        option :location_elsewhere

        on_response do |response|
          calculator.business_premises = response
        end

        next_node do
          outcome :results
        end
      end

      # ======================================================================
      # Outcome
      # ======================================================================
      outcome :results
    end
  end
end
