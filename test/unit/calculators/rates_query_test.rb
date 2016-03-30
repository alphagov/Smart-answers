require_relative "../../test_helper"

module SmartAnswer::Calculators
  class RatesQueryTest < ActiveSupport::TestCase
    context SmartAnswer::Calculators::RatesQuery do
      context "#rates" do
        should "be 1 for 2013-01-31" do
          test_rate = SmartAnswer::Calculators::RatesQuery.new('exact_date_rates')
          test_rate.stubs(:load_path).returns(File.join("test", "fixtures", "rates"))
          assert_equal 1, test_rate.rates(Date.parse('2013-01-31')).rate
        end

        should "be 2 for 2013-02-01" do
          test_rate = SmartAnswer::Calculators::RatesQuery.new('exact_date_rates')
          test_rate.stubs(:load_path).returns(File.join("test", "fixtures", "rates"))
          assert_equal 2, test_rate.rates(Date.parse('2013-02-01')).rate
        end

        should "be the latest known rate (2) for uncovered future dates" do
          test_rate = SmartAnswer::Calculators::RatesQuery.new('exact_date_rates')
          test_rate.stubs(:load_path).returns(File.join("test", "fixtures", "rates"))
          assert_equal 2, test_rate.rates(Date.parse('2113-03-12')).rate
        end

        context 'given a rate has been loaded for one date' do
          setup do
            @test_rate = SmartAnswer::Calculators::RatesQuery.new('exact_date_rates')
            @test_rate.stubs(:load_path).returns(File.join("test", "fixtures", "rates"))
            @test_rate.rates(Date.parse('2013-01-31')).rate
          end

          should 'return the correct rate for a different date' do
            assert_equal 2, @test_rate.rates(Date.parse("2013-02-01")).rate
          end
        end
      end

      context "Married couples allowance" do
        setup do
          @query = SmartAnswer::Calculators::RatesQuery.new('married_couples_allowance')
        end

        should "have all required rates defined for the current fiscal year" do
          %w(personal_allowance over_65_allowance over_75_allowance income_limit_for_personal_allowances maximum_married_couple_allowance minimum_married_couple_allowance).each do |rate|
            assert @query.rates.send(rate).is_a?(Numeric)
          end
        end

        context "personal_allowance" do
          should "be the latest known walue on 15th April 2116 (fallback)" do
            assert @query.rates(Date.parse("2116-04-15")).personal_allowance.is_a?(Numeric)
          end

          should "be 10600 on 5th April 2016" do
            assert_equal 10600, @query.rates(Date.parse("2016-04-05")).personal_allowance
          end

          should "be 9440 on 6th April 2013" do
            assert_equal 9440, @query.rates(Date.parse("2013-04-06")).personal_allowance
          end

          should "be 10000 on 6th April 2014" do
            assert_equal 10000, @query.rates(Date.parse("2014-04-06")).personal_allowance
          end
        end
      end

      context 'register a birth fees' do
        context 'for 2015/16' do
          should 'be £105 for registering a birth' do
            rates_query = SmartAnswer::Calculators::RatesQuery.new('register_a_birth')
            sixth_april_2015 = Date.parse('2015-04-06')
            assert_equal 105, rates_query.rates(sixth_april_2015).register_a_birth
          end

          should 'be £65 for a copy of the birth registration certificate' do
            rates_query = SmartAnswer::Calculators::RatesQuery.new('register_a_birth')
            sixth_april_2015 = Date.parse('2015-04-06')
            assert_equal 65, rates_query.rates(sixth_april_2015).copy_of_birth_registration_certificate
          end
        end

        context 'for 2016/17' do
          should 'be £150 for registering a birth' do
            rates_query = SmartAnswer::Calculators::RatesQuery.new('register_a_birth')
            sixth_april_2015 = Date.parse('2016-04-06')
            assert_equal 150, rates_query.rates(sixth_april_2015).register_a_birth
          end

          should 'be £50 for a copy of the birth registration certificate' do
            rates_query = SmartAnswer::Calculators::RatesQuery.new('register_a_birth')
            sixth_april_2015 = Date.parse('2016-04-06')
            assert_equal 50, rates_query.rates(sixth_april_2015).copy_of_birth_registration_certificate
          end
        end
      end
    end
  end
end
