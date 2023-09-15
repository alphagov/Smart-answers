require_relative "../../test_helper"

module SmartAnswer
  module Calculators
    class RegisterADeathCalculatorTest < ActiveSupport::TestCase
      setup do
        @calculator = RegisterADeathCalculator.new
        @stub_rates_query = RatesQuery.stubs(:from_file).with("register_a_death")
      end

      context "fee_for_registering_a_death" do
        should "return correct fee for registering a death" do
          rates_query = stub(rates: OpenStruct.new({ register_a_death: 2.00 }))
          @stub_rates_query.returns(rates_query)
          assert_equal 2.00, @calculator.fee_for_registering_a_death
        end
      end

      context "fee_for_copy_of_death_registration_certificate" do
        should "return correct fee for copy of a death registration certificate" do
          rates_query = stub(rates: OpenStruct.new({ copy_of_death_registration_certificate: 10.00 }))
          @stub_rates_query.returns(rates_query)
          assert_equal 10.00, @calculator.fee_for_copy_of_death_registration_certificate
        end
      end
    end
  end
end
