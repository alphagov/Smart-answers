require_relative "../../test_helper"

module SmartAnswer::Calculators
  class StatePensionAmountCalculatorTest < ActiveSupport::TestCase
    context "male, born 5th April 1945, 45 qualifying years" do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "male", dob: "1945-04-05", qualifying_years: "45")
      end

      should "be 107.45 for what_you_get" do
        assert_equal 107.45, @calculator.what_you_get
      end

      should "be 102.27 for you_get_future" do
        assert_equal 102.27, @calculator.you_get_future
      end
    end

    context "female, born 7th April 1951, 39 qualifying years" do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "female", dob: "1951-04-07", qualifying_years: "45")
      end

      should "be 107.45 for what_you_get" do
        assert_equal 107.45, @calculator.what_you_get
      end

      should "be 107.45 for you_get_future" do
        assert_equal 107.45, @calculator.you_get_future
      end
    end

    context "female, born 7th April 1951, 20 qualifying years" do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "female", dob: "1951-04-07", qualifying_years: "20")
      end

      should "be 107.45 for what_you_get" do
        assert_equal 48.84, @calculator.what_you_get
      end

      should "be 107.45 for you_get_future" do
        assert_equal 107.45, @calculator.you_get_future
      end
    end
    
    context "female, born 29th Feb 1968" do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "female", dob: "1968-02-29", qualifying_years: nil)
      end

      should "be elligible for state pension on 1 March 2034" do
        assert_equal Date.parse("2034-03-01"), @calculator.state_pension_date
      end
      
      should "be elligible for three years of credit regardless of benefits claimed" do
        assert @calculator.three_year_credit_age?
      end
      
    end
    
  end
end
