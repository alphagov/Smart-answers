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

      should "be 5 automatic years" do
        @calculator.allocate_automatic_years
        assert_equal 5, @calculator.automatic_years
      end
    end

    context "female, born 7th April 1951, 39 qualifying years" do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "female", dob: "1951-04-07", qualifying_years: "45")
      end

      should "be 107.45 for what_you_get" do
        assert_equal 107.45, @calculator.what_you_get
      end

      should "be 4 automatic years" do
        assert_equal 4, @calculator.allocate_automatic_years
      end
    end

    context "female, born 7th April 1951, 20 qualifying years" do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "female", dob: "1951-04-07", qualifying_years: "20")
      end

      should "be 20/30 of 107.45 for what_you_get" do
        assert_equal 71.63, @calculator.what_you_get
      end

    end
    
    context "female, born 29th Feb 1968" do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "female", dob: "1968-02-29", qualifying_years: nil)
      end

      should "be eligible for state pension on 1 March 2034" do
        assert_equal Date.parse("2034-03-01"), @calculator.state_pension_date
      end
      
      should "be eligible for three years of credit regardless of benefits claimed" do
        assert @calculator.three_year_credit_age?
      end
      
      should "be 0 automatic years" do
        assert_equal 0, @calculator.allocate_automatic_years
      end
    end
    
    context "female born 6 Oct 1953 " do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "female", dob: "1953-10-06", qualifying_years: nil)
      end
      
      should "qualifying_years_credit = 0" do
        assert_equal 0, @calculator.qualifying_years_credit
      end
    end 

    context "female born 6 Oct 1992 " do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "female", dob: "1992-10-06", qualifying_years: nil)
      end
      
      should "qualifying_years_credit = 2" do
        assert_equal 2, @calculator.qualifying_years_credit
      end
    end 

    # one of HMRC test cases
    context "female born 6 April 1992 " do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "female", dob: "1992-04-06", qualifying_years: nil)
      end
      
      should "qualifying_years_credit = 2" do
        assert_equal 2, @calculator.qualifying_years_credit
      end

      should "get 2/30 of 107.45 for what_you_get" do
        @calculator.qualifying_years = 2
        assert_equal 7.16, @calculator.what_you_get
      end
    end 

    context "male born 6 April 1957 " do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "female", dob: "1957-04-06", qualifying_years: nil)
      end
      
      should "qualifying_years_credit = 1" do
        assert_equal 1, @calculator.qualifying_years_credit
      end
    end


    context "female born 6 Oct 1949 " do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "female", dob: "1949-10-06", qualifying_years: nil)
      end
      
      should "allocate_automatic_years = 5" do
        assert_equal 5, @calculator.allocate_automatic_years
      end
    end 
    
    context "female born 6 Aug 1953 " do
      setup do
        @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "female", dob: "1953-08-06", qualifying_years: nil)
      end
      
      should "allocate_automatic_years = 1" do
        assert_equal 1, @calculator.allocate_automatic_years
      end
    end 

    context "female born 22 years ago" do
      should "return ni_years_to_date = 3" do
        dob = 22.years.ago.to_s
        @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "female", dob: dob, qualifying_years: nil)
        assert_equal 3, @calculator.available_years
      end
      should "return ni_years_to_date = 3" do
        dob = (22.years.ago + 3.months).to_s
        @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "female", dob: dob, qualifying_years: nil)
        assert_equal 2, @calculator.available_years
      end
      should "return ni_years_to_date = 2" do
        dob = (22.years.ago - 3.months).to_s
        @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "female", dob: dob, qualifying_years: nil)
        assert_equal 3, @calculator.available_years
      end
    end
    

    context "test available years functions" do
      context "male born 26 years and one month plus, no qualifying_years" do
        setup do
          dob = 1.month.since(26.years.ago).to_s
          @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "male", dob: dob, qualifying_years: nil)
        end

        should "avialable_years = 6" do
          assert_equal 6, @calculator.available_years
        end
      end
      context "male born 26 years and one month ago, no qualifying_years" do
        setup do
          dob = 1.month.ago(26.years.ago).to_s
          @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "male", dob: dob, qualifying_years: nil)
        end

        should "avialable_years = 7" do
          assert_equal 7, @calculator.available_years
        end
      end
      # NOTE: leave this test in case we need to turn on the day calculation
      # context "male born 26 years and one day in future, no qualifying_years" do
      #   setup do
      #     dob = 1.day.since(26.years.ago).to_s
      #     @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "male", dob: dob, qualifying_years: nil)
      #   end

      #   should "avialable_years = 6" do
      #     assert_equal 6, @calculator.available_years
      #   end
      # end
      context "male born 26 years and one day ago, no qualifying_years" do
        setup do
          dob = 1.day.ago(26.years.ago).to_s
          @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "male", dob: dob, qualifying_years: nil)
        end

        should "avialable_years = 7" do
          assert_equal 7, @calculator.available_years
        end
      end
      context "male born 26 years, no qualifying_years" do
        setup do
          dob = 26.years.ago.to_s
          @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(gender: "male", dob: dob, qualifying_years: nil)
        end

        should "avialable_years = 7" do
          assert_equal 7, @calculator.available_years
        end
      end

      context "32 years old with 10 qualifying_years" do
        setup do
          dob = 32.years.ago.to_s
          @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(
            gender: "female", dob: dob, qualifying_years: 10)
        end

        should "available_years = 13; available_years_sum = 3" do
          assert_equal 13, @calculator.available_years
          assert_equal 3, @calculator.available_years_sum
        end

        should "has_available_years? return true" do
          assert @calculator.has_available_years?
        end

        should "has_available_years?(13) return false" do
          assert ! @calculator.has_available_years?(14)
        end

        should "not_qualifying_or_available_test?(13) return true" do
          assert @calculator.not_qualifying_or_available_test?(13)
        end

        should "not_qualifying_or_available_test? return true" do
          assert ! @calculator.not_qualifying_or_available_test?
        end
      end

      
      context "(testing qualifying_years from years_of_work) born 5th May 1957" do
        setup do
          dob = "5th May 1957"
          years = 29
          @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(
            gender: "male", dob: dob, qualifying_years: years)
        end

        should "three_year_credit_age = false" do
          assert ! @calculator.three_year_credit_age?
        end
        context "simulate a entries in years_of_work question" do
          should "upon 3 calc_qualifying_years_credit: 0" do
            entered_num = 3
            assert_equal 0, @calculator.calc_qualifying_years_credit(entered_num)
          end
          should "upon 2 calc_qualifying_years_credit: 0" do
            entered_num = 2
            assert_equal 0, @calculator.calc_qualifying_years_credit(entered_num)
          end
          should "upon 1 calc_qualifying_years_credit: 0" do
            entered_num = 1
            assert_equal 0, @calculator.calc_qualifying_years_credit(entered_num)
          end
          should "upon 0 calc_qualifying_years_credit: 0" do
            entered_num = 0
            assert_equal 1, @calculator.calc_qualifying_years_credit(entered_num)
          end
        end
      end

      context "(testing qualifying_years from years_of_work) born 5th May 1958" do
        setup do
          dob = "5th May 1958"
          years = 29
          @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(
            gender: "male", dob: dob, qualifying_years: years)
        end

        should "three_year_credit_age = false" do
          assert ! @calculator.three_year_credit_age?
        end
        context "simulate a entries in years_of_work question" do
          should "upon 3 calc_qualifying_years_credit: 0" do
            entered_num = 3
            assert_equal 0, @calculator.calc_qualifying_years_credit(entered_num)
          end
          should "upon 2 calc_qualifying_years_credit: 0" do
            entered_num = 2
            assert_equal 0, @calculator.calc_qualifying_years_credit(entered_num)
          end
          should "upon 1 calc_qualifying_years_credit: 0" do
            entered_num = 1
            assert_equal 1, @calculator.calc_qualifying_years_credit(entered_num)
          end
          should "upon 0 calc_qualifying_years_credit: 0" do
            entered_num = 0
            assert_equal 2, @calculator.calc_qualifying_years_credit(entered_num)
          end
        end
      end

      context "years_can_be_entered test" do
        should "should return 5" do
          @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(
            gender: "male", dob: 49.years.ago.to_s, qualifying_years: 25)
          assert_equal 5, @calculator.available_years_sum
          assert_equal 5, @calculator.years_can_be_entered(@calculator.available_years_sum,22)
        end
        should "should return 22" do
          @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(
            gender: "male", dob: 49.years.ago.to_s, qualifying_years: 5)
          assert_equal 25, @calculator.available_years_sum
          assert_equal 22, @calculator.years_can_be_entered(@calculator.available_years_sum,22)
        end
      end

      context "(testing years_to_pension)" do
        
        should "years_to_pension : 32 on dob: 1977-04-12" do
          Timecop.travel(Date.parse("2012-08-01")) do
            @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(
              gender: "male", dob: "1977-04-12", qualifying_years: nil)
            assert_equal 32, @calculator.years_to_pension
          end
        end
        should "years_to_pension : 33 on dob: 1977-11-12" do
          Timecop.travel(Date.parse("2012-08-01")) do
            @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(
              gender: "male", dob: "1977-11-12", qualifying_years: nil)
            assert_equal 33, @calculator.years_to_pension
          end
        end

        should "years_to_pension : 34 on dob: 1977-11-12" do
          Timecop.freeze(Date.parse("2012-01-01")) do
            @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(
              gender: "male", dob: "1977-11-12", qualifying_years: nil)
            assert_equal 34, @calculator.years_to_pension
          end
        end
      end
    end

    context "state_pension_age tests" do
      context "testing dynamic pension dates" do
        should "be 66 years, date 2029-11-10" do
          @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(
              gender: "male", dob: "1963-11-10", qualifying_years: nil)
          assert_equal "66 years", @calculator.state_pension_age
          assert_equal Date.parse("2029-11-10"), @calculator.state_pension_date
        end
        should "be 68 years, 2047-04-06" do
          @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(
              gender: "male", dob: "1979-04-06", qualifying_years: nil)
          assert_equal "68 years", @calculator.state_pension_age
          assert_equal Date.parse("2047-04-06"), @calculator.state_pension_date
        end
        should "be 68 years, 2047-04-06" do
          @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(
              gender: "male", dob: "1979-04-06", qualifying_years: nil)
          assert_equal "68 years", @calculator.state_pension_age
          assert_equal Date.parse("2047-04-06"), @calculator.state_pension_date
        end
        should "be 68 years, 2052-01-01" do
          @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(
              gender: "male", dob: "1984-01-01", qualifying_years: nil)
          assert_equal "68 years", @calculator.state_pension_age
          assert_equal Date.parse("2052-01-01"), @calculator.state_pension_date
        end
      end
      context "testing set pension dates from data file" do
        should "67 years, 1 day; 2044-05-06" do
          @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(
              gender: "male", dob: "1977-05-05", qualifying_years: nil)
          assert_equal Date.parse("2044-05-06"), @calculator.state_pension_date
          assert_equal "67 years, 1 day", @calculator.state_pension_age
        end
        should "65 years, 10 months and 23 days; dob: 1968-02-29; pension date: 2034-03-01 " do
          @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(
              gender: "male", dob: "1968-02-29", qualifying_years: nil)
          # assert_equal "65 years, 10 months and 23 days", @calculator.state_pension_age
          assert_equal "66 years, 1 day", @calculator.state_pension_age
          assert_equal Date.parse("2034-03-01"), @calculator.state_pension_date
        end
        should "66 years, 7 months, 2 days; 2035-05-06" do
          @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(
              gender: "male", dob: "1968-10-06", qualifying_years: nil)
          assert_equal "66 years, 7 months, 2 days", @calculator.state_pension_age
          assert_equal Date.parse("2035-05-06"), @calculator.state_pension_date
        end
        should "66 years, 6 months, 2 days; 2035-05-06" do
          @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(
              gender: "male", dob: "1968-11-05", qualifying_years: nil)
          assert_equal "66 years, 6 months, 2 days", @calculator.state_pension_age
          assert_equal Date.parse("2035-05-06"), @calculator.state_pension_date
        end
        should "66 years, 7 months, 2 days; 2035-05-06" do
          @calculator = SmartAnswer::Calculators::StatePensionAmountCalculator.new(
              gender: "male", dob: "1968-11-06", qualifying_years: nil)
          assert_equal "66 years, 8 months, 2 days", @calculator.state_pension_age
          assert_equal Date.parse("2035-07-06"), @calculator.state_pension_date
        end
      end
    end
  end
end
