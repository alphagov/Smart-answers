require_relative "../../test_helper"

module SmartAnswer
  module Calculators
    class StudentFinanceCalculatorTest < ActiveSupport::TestCase
      context "#maintenance_grant_amount" do
        context "for students who started 2016-2017 or later" do
          setup do
            @course_start = '2016-2017'
          end
          should "return 0 for any student" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 15_000,
              residence: :unused_variable
            )
            assert_equal Money.new(0).to_s, calculator.maintenance_grant_amount.to_s
          end
        end
      end

      context "#maintenance_loan_amount" do
        context "for students who started 2016-2017 living at home with parents" do
          setup do
            @course_start = '2016-2017'
            @residence = 'at-home'
          end

          should "give the maximum amount of £6,904 if household income is £25k or below" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 25_000,
              residence: @residence
            )
            assert_equal Money.new(6_904).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "reduce the maximum amount (£6,904) by £1 for every complete £8.59 of income above £25k" do
            # Samples taken from the document provided
            {
              30_000 => 6_322,
              35_000 => 5_740,
              40_000 => 5_158,
              42_875 => 4_824,
              45_000 => 4_576,
              50_000 => 3_994,
              55_000 => 3_412,
              58_201 => 3_039
            }.each do |household_income, loan_amount|
              calculator = StudentFinanceCalculator.new(
                course_start: @course_start,
                household_income: household_income,
                residence: @residence
              )
              assert_equal Money.new(loan_amount).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          should "cap the reductions and give the minimum loan of £3,039 for high household income students" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 500_000,
              residence: @residence
            )
            assert_equal Money.new(3_039).to_s, calculator.maintenance_loan_amount.to_s
          end
        end

        context "for students who started 2017-2018 living at home with parents" do
          setup do
            @course_start = '2017-2018'
            @residence = 'at-home'
          end

          should "give the maximum amount of £7,097 if household income is £25k or below" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 25_000,
              residence: @residence
            )
            assert_equal Money.new(7_097).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "reduce the maximum amount (£7,097) by £1 for every complete £8.36 of income above £25k" do
            # Samples taken from the document provided
            {
              30_000 => 6_499,
              35_000 => 5_901,
              40_000 => 5_303,
              42_875 => 4_959,
              45_000 => 4_705,
              50_000 => 4_107,
              55_000 => 3_509,
              58_215 => 3_124,
              60_000 => 3_124,
              65_000 => 3_124
            }.each do |household_income, loan_amount|
              calculator = StudentFinanceCalculator.new(
                course_start: @course_start,
                household_income: household_income,
                residence: @residence
              )
              assert_equal Money.new(loan_amount).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          should "cap the reductions and give the minimum loan of £3,124 for high household income students" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 500_000,
              residence: @residence
            )
            assert_equal Money.new(3_124).to_s, calculator.maintenance_loan_amount.to_s
          end
        end

        context "for students who started 2016-2017 living away not in london" do
          setup do
            @course_start = '2016-2017'
            @residence = 'away-outside-london'
          end

          should "give the maximum amount of £8,200 if household income is £25k or below" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 25_000,
              residence: @residence
            )
            assert_equal Money.new(8_200).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "reduce the maximum amount (£8,200) by £1 for every complete £8.49 of income above £25k" do
            # Samples taken from the document provided
            {
              30_000 => 7_612,
              35_000 => 7_023,
              40_000 => 6_434,
              42_875 => 6_095,
              45_000 => 5_845,
              50_000 => 5_256,
              55_000 => 4_667,
              60_000 => 4_078,
              62_180 => 3_821
            }.each do |household_income, loan_amount|
              calculator = StudentFinanceCalculator.new(
                course_start: @course_start,
                household_income: household_income,
                residence: @residence
              )
              assert_equal Money.new(loan_amount).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          should "cap the reductions and give the minimum loan of £3,821 for high household income students" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 500_000,
              residence: @residence
            )
            assert_equal Money.new(3_821).to_s, calculator.maintenance_loan_amount.to_s
          end
        end

        context "for students who started 2017-2018 living away not in london" do
          setup do
            @course_start = '2017-2018'
            @residence = 'away-outside-london'
          end

          should "give the maximum amount of £8,430 if household income is £25k or below" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 25_000,
              residence: @residence
            )
            assert_equal Money.new(8_430).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "reduce the maximum amount (£8,430) by £1 for every complete £8.26 of income above £25k" do
            # Samples taken from the document provided
            {
              30_000 => 7_825,
              35_000 => 7_220,
              40_000 => 6_615,
              42_875 => 6_266,
              45_000 => 6_009,
              50_000 => 5_404,
              55_000 => 4_799,
              60_000 => 4_193,
              62_187 => 3_928,
              65_000 => 3_928,
              70_000 => 3_928
            }.each do |household_income, loan_amount|
              calculator = StudentFinanceCalculator.new(
                course_start: @course_start,
                household_income: household_income,
                residence: @residence
              )
              assert_equal Money.new(loan_amount).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          should "cap the reductions and give the minimum loan of £3,928 for high household income students" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 500_000,
              residence: @residence
            )
            assert_equal Money.new(3_928).to_s, calculator.maintenance_loan_amount.to_s
          end
        end

        context "for students who started 2016-2017 living away in london" do
          setup do
            @course_start = '2016-2017'
            @residence = 'away-in-london'
          end

          should "give the maximum amount of £10,702 if household income is £25k or below" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 25_000,
              residence: @residence
            )
            assert_equal Money.new(10_702).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "reduce the maximum amount (£10,702) by £1 for every complete £8.34 of income above £25k" do
            # Samples taken from the document provided
            {
              30_000 => 10_103,
              35_000 => 9_503,
              40_000 => 8_904,
              42_875 => 8_559,
              45_000 => 8_304,
              50_000 => 7_705,
              55_000 => 7_105,
              60_000 => 6_506,
              65_000 => 5_906,
              69_803 => 5_330
            }.each do |household_income, loan_amount|
              calculator = StudentFinanceCalculator.new(
                course_start: @course_start,
                household_income: household_income,
                residence: @residence
              )
              assert_equal Money.new(loan_amount).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          should "cap the reductions and give the minimum loan of £5,330 for high household income students" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 500_000,
              residence: @residence
            )
            assert_equal Money.new(5_330).to_s, calculator.maintenance_loan_amount.to_s
          end
        end

        context "for students who started 2017-2018 living away in london" do
          setup do
            @course_start = '2017-2018'
            @residence = 'away-in-london'
          end

          should "give the maximum amount of £11,002 if household income is £25k or below" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 25_000,
              residence: @residence
            )
            assert_equal Money.new(11_002).to_s, calculator.maintenance_loan_amount.to_s
          end

          should "reduce the maximum amount (£11,002) by £1 for every complete £8.12 of income above £25k" do
            # Samples taken from the document provided
            {
               30_000 => 10_387,
               35_000 => 9_771,
               40_000 => 9_155,
               42_875 => 8_801,
               45_000 => 8_539,
               50_000 => 7_924,
               55_000 => 7_308,
               60_000 => 6_692,
               65_000 => 6_076,
               69_847 => 5_479,
               70_000 => 5_479
            }.each do |household_income, loan_amount|
              calculator = StudentFinanceCalculator.new(
                course_start: @course_start,
                household_income: household_income,
                residence: @residence
              )
              assert_equal Money.new(loan_amount).to_s, calculator.maintenance_loan_amount.to_s
            end
          end

          should "cap the reductions and give the minimum loan of £5,479 for high household income students" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: 500_000,
              residence: @residence
            )
            assert_equal Money.new(5_479).to_s, calculator.maintenance_loan_amount.to_s
          end
        end

        context "#reduced_maintenance_loan_for_healthcare" do
          should "be £3263 for students living away from home in London" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              residence: 'away-in-london'
            )

            assert_equal 3263, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £2324 for students living away from home outside London" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              residence: 'away-outside-london'
            )

            assert_equal 2324, calculator.reduced_maintenance_loan_for_healthcare
          end

          should "be £1744 for students living away from home outside London" do
            calculator = StudentFinanceCalculator.new(
              course_start: @course_start,
              household_income: @household_income,
              residence: 'at-home'
            )

            assert_equal 1744, calculator.reduced_maintenance_loan_for_healthcare
          end
        end
      end
    end
  end
end
