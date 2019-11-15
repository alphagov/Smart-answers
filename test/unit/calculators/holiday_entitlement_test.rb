require_relative "../../test_helper"

module SmartAnswer::Calculators
  class HolidayEntitlementTest < ActiveSupport::TestCase
    context "calculate entitlement on days worked per week" do
      context "for a full leave year" do
        # /days-worked-per-week/full-year/5.0
        should "for 5 days a week" do
          calc = HolidayEntitlement.new(working_days_per_week: 5)
          assert_equal "28", calc.formatted_full_time_part_time_days
        end

        # /days-worked-per-week/full-year/5.0
        should "for more than 5 days a week" do
          calc = HolidayEntitlement.new(working_days_per_week: 7)
          assert_equal "28", calc.formatted_full_time_part_time_days
        end

        # /days-worked-per-week/full-year/3.5
        should "for less than 5 days a week" do
          calc = HolidayEntitlement.new(working_days_per_week: 3.5)
          assert_equal "19.6", calc.formatted_full_time_part_time_days
        end

        context "for department test data" do
          # Dept Test 1 - /days-worked-per-week/full-year/6.0
          should "for less than 5 days a week (dept Test 1)" do
            calc = HolidayEntitlement.new(working_days_per_week: 6)
            assert_equal "28", calc.formatted_full_time_part_time_days
          end

          # Dept Test 2 - /days-worked-per-week/full-year/3.5
          should "for less than 5 days a week (dept Test 2)" do
            calc = HolidayEntitlement.new(working_days_per_week: 3.5)
            assert_equal "19.6", calc.formatted_full_time_part_time_days
          end

          # Dept Test 3 - /days-worked-per-week/full-year/2.0
          should "for less than 5 days a week (dept Test 3)" do
            calc = HolidayEntitlement.new(working_days_per_week: 2)
            assert_equal "11.2", calc.formatted_full_time_part_time_days
          end

          # Dept Test 4 - /days-worked-per-week/full-year/1.0
          should "for less than 5 days a week (dept Test 4)" do
            calc = HolidayEntitlement.new(working_days_per_week: 1)
            assert_equal "5.6", calc.formatted_full_time_part_time_days
          end

          # Dept Test 5 - /days-worked-per-week/full-year/1.0
          should "for less than 5 days a week (dept Test 5)" do
            calc = HolidayEntitlement.new(working_days_per_week: 0.5)
            assert_equal "2.8", calc.formatted_full_time_part_time_days
          end

          #Dept Test 6 is a data entry validation for entering 8 days a week covered in
          #test/integration/smart_answer_flows/calculate_your_holiday_entitlement_test.rb
        end
      end

      context "starting part way through a leave year" do
        context "for a standard year" do
          # /days-worked-per-week/starting/2019-06-01/2019-01-01/5.0
          should "for 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-06-01"),
              leave_year_start_date: Date.parse("2019-01-01"),
              working_days_per_week: 5,
            )

            assert_equal BigDecimal("0.5833333333").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("16.3333333333").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "16.5", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2019-11-21/2019-04-01/3.0
          should "for less than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-11-23"),
              leave_year_start_date: Date.parse("2019-04-01"),
              working_days_per_week: 3,
            )

            assert_equal BigDecimal("0.4166666667").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("7.0").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "7", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2019-11-14/2019-01-01/6.0
          should "for more than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-11-14"),
              leave_year_start_date: Date.parse("2019-01-01"),
              working_days_per_week: 6,
            )

            assert_equal BigDecimal("0.1666666667").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("4.6666666667").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "5", calc.formatted_full_time_part_time_days
          end
        end

        context "for a leap year" do
          # /days-worked-per-week/starting/2020-06-01/2020-01-01/5.0
          should "for 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-06-01"),
              leave_year_start_date: Date.parse("2020-01-01"),
              working_days_per_week: 5,
            )

            assert_equal BigDecimal("0.5833333333").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("16.3333333333").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "16.5", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2020-11-21/2020-04-01/3.0
          should "for less than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-11-23"),
              leave_year_start_date: Date.parse("2020-04-01"),
              working_days_per_week: 3,
            )

            assert_equal BigDecimal("0.4166666667").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("7.0").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "7", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2020-11-14/2020-01-01/6.0
          should "for more than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-11-14"),
              leave_year_start_date: Date.parse("2020-01-01"),
              working_days_per_week: 6,
            )

            assert_equal BigDecimal("0.1666666667").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("4.6666666667").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "5", calc.formatted_full_time_part_time_days
          end
        end

        context "for department test data" do
          # Dept Test 7 - /days-worked-per-week/starting/2021-02-09/2020-08-01/3.0
          should "for less than 3 days a week (dept Test 7)" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2021-02-09"),
              leave_year_start_date: Date.parse("2020-08-01"),
              working_days_per_week: 3,
            )

            assert_equal "8.5", calc.formatted_full_time_part_time_days
          end

          # Dept Test 8 - /days-worked-per-week/starting/2019-09-23/2019-05-01/5.0
          should "for 5 days a week (dept Test 8)" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-09-23"),
              leave_year_start_date: Date.parse("2019-05-01"),
              working_days_per_week: 5,
              )

            assert_equal "19", calc.formatted_full_time_part_time_days
          end

          # Dept Test 9 - /days-worked-per-week/starting/2020-02-13/2019-07-01/1.0
          should "for 1 day a week (dept Test 9)" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-02-13"),
              leave_year_start_date: Date.parse("2019-07-01"),
              working_days_per_week: 1,
            )

            assert_equal "2.5", calc.formatted_full_time_part_time_days
          end

          # Dept Test 10 - /days-worked-per-week/starting/2018-10-28/2018-04-01/1.0
          should "for 1 day a week (dept Test 10)" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2018-10-28"),
              leave_year_start_date: Date.parse("2018-04-01"),
              working_days_per_week: 1,
            )

            assert_equal "3", calc.formatted_full_time_part_time_days
          end

          # Dept Test 11 - /days-worked-per-week/starting/2019-05-10/2018-06-06/2.0
          should "for 2 days a week (dept Test 11)" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-05-10"),
              leave_year_start_date: Date.parse("2018-06-06"),
              working_days_per_week: 2,
            )

            assert_equal "1", calc.formatted_full_time_part_time_days
          end

          # Dept Test 12 - /days-worked-per-week/starting/2020-03-03/2020-03-01/4.0
          should "for 4 days a week (dept Test 12)" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-03-03"),
              leave_year_start_date: Date.parse("2020-03-01"),
              working_days_per_week: 4,
            )

            assert_equal "22.5", calc.formatted_full_time_part_time_days
          end
        end
      end

      context "leaving part way through a leave year" do
        context "for a standard year" do
          # /days-worked-per-week/starting/2019-06-01/2019-01-01/5.0
          should "for 5 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2019-06-01"),
              leave_year_start_date: Date.parse("2019-01-01"),
              working_days_per_week: 5,
            )

            assert_equal BigDecimal("0.4164383562").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("11.6602739726").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "11.7", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2019-11-21/2019-04-01/3.0
          should "for less than 5 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2018-11-23"),
              leave_year_start_date: Date.parse("2018-04-01"),
              working_days_per_week: 3,
            )
            assert_equal BigDecimal("0.6493150685").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("10.9084931507").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "11", calc.formatted_full_time_part_time_days
          end
        end

        context "for a leap year" do
          # /days-worked-per-week/starting/2020-06-01/2020-01-01/5.0
          should "for 5 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-06-01"),
              leave_year_start_date: Date.parse("2020-01-01"),
              working_days_per_week: 5,
            )

            assert_equal BigDecimal("0.4180327869").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("11.7049180328").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "11.8", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2020-11-21/2020-04-01/3.0
          should "for less than 5 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2019-11-23"),
              leave_year_start_date: Date.parse("2019-04-01"),
              working_days_per_week: 3,
            )

            assert_equal BigDecimal("0.6475409836").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("10.8786885246").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "10.9", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2020-08-22/2020-01-01/6.0
          should "for more than 5 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-08-22"),
              leave_year_start_date: Date.parse("2020-01-01"),
              working_days_per_week: 6,
            )

            assert_equal BigDecimal("0.6420765027").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("17.9781420765").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "18", calc.formatted_full_time_part_time_days
          end
        end

        context "for department test data" do
          # /days-worked-per-week/leaving/2020-10-20/2020-05-01/5.0
          should "for 5 days a week (dept test 13)" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-10-20"),
              leave_year_start_date: Date.parse("2020-05-01"),
              working_days_per_week: 5,
            )

            assert_equal BigDecimal("0.4739726027").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("13.2712328767").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "13.3", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/leaving/2020-06-18/2019-12-01/6.0
          should "for 6 days a week (dept test 14)" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-06-18"),
              leave_year_start_date: Date.parse("2019-12-01"),
              working_days_per_week: 6,
            )
            assert_equal BigDecimal("0.5491803279").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("15.3770491803").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "15.4", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/leaving/2020-03-17/2019-06-01/7.0
          should "for 7days a week (dept test 15)" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-03-17"),
              leave_year_start_date: Date.parse("2019-06-01"),
              working_days_per_week: 7,
            )

            assert_equal BigDecimal("0.7950819672").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("22.262295082").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "22.3", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/leaving/2019-09-06/2019-03-01/6.0
          should "for 6 days a week (dept test 16)" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2019-09-06"),
              leave_year_start_date: Date.parse("2019-03-01"),
              working_days_per_week: 6,
            )

            assert_equal BigDecimal("0.5191256831").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("14.5355191257").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "14.6", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/leaving/2018-02-01/2018-05-05/3.0
          should "for 3 days a week (dept test 17)" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2018-05-05"),
              leave_year_start_date: Date.parse("2018-02-01"),
              working_days_per_week: 3,
            )

            assert_equal BigDecimal("0.2575342466").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("4.3265753425").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "4.4", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/leaving/2020-06-04/2019-11-01/4.0
          should "for 4 days a week (dept test 18)" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-06-04"),
              leave_year_start_date: Date.parse("2019-11-01"),
              working_days_per_week: 4,
            )

            assert_equal BigDecimal("0.5928961749").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("13.2808743169").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "13.3", calc.formatted_full_time_part_time_days
          end
        end
      end

      context "starting and leaving part way through a leave year" do
        context "for a standard year" do
          # /days-worked-per-week/starting/2020-01-20/2020-08-07/5.0
          should "for 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-01-20"),
              leaving_date: Date.parse("2019-07-18"),
              working_days_per_week: 5,
            )

            assert_equal BigDecimal("0.4931506849").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("13.8082191780822").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "13.9", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2019-11-23/2020-04-07/3.0
          should "for less than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2018-11-23"),
              leaving_date: Date.parse("2019-04-07"),
              working_days_per_week: 3,
            )

            assert_equal BigDecimal("0.3726027397").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("6.2597260274").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "6.3", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2019-08-22/2020-07-31/6.0
          should "for more than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2018-08-22"),
              leaving_date: Date.parse("2019-07-31"),
              working_days_per_week: 6,
            )

            assert_equal BigDecimal("0.9424657534").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("26.3890410959").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "26.4", calc.formatted_full_time_part_time_days
          end
        end

        context "for a leap year" do
          # /days-worked-per-week/starting/2020-01-20/2020-08-07/5.0
          should "for 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-01-20"),
              leaving_date: Date.parse("2020-07-18"),
              working_days_per_week: 5,
            )

            assert_equal BigDecimal("0.4945355191").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("13.8469945355").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "13.9", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2019-11-23/2020-04-07/3.0
          should "for less than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-11-23"),
              leaving_date: Date.parse("2020-04-07"),
              working_days_per_week: 3,
            )

            assert_equal BigDecimal("0.3743169399").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("6.2885245902").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "6.3", calc.formatted_full_time_part_time_days
          end

          # /days-worked-per-week/starting/2019-08-22/2020-07-31/6.0
          should "for more than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-08-22"),
              leaving_date: Date.parse("2020-07-31"),
              working_days_per_week: 6,
            )

            assert_equal BigDecimal("0.9426229508").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("26.3934426229508").round(10), calc.full_time_part_time_days.round(10)
            assert_equal "26.4", calc.formatted_full_time_part_time_days
          end
        end

        context "for department test data" do
          # /days-worked-per-week/starting-and-leaving/2019-08-09/2020-01-01/2.0
          should "for  2 days a week (dept test 19)" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-08-09"),
              leaving_date: Date.parse("2020-01-01"),
              working_days_per_week: 2,
            )

            assert_equal "4.5", calc.formatted_full_time_part_time_days
          end
          # /days-worked-per-week/starting-and-leaving/2019-11-01/2020-05-27/6.0
          should "for 6 days a week (dept test 20)" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-11-01"),
              leaving_date: Date.parse("2020-05-27"),
              working_days_per_week: 6,
            )

            assert_equal "16", calc.formatted_full_time_part_time_days
          end
          # /days-worked-per-week/starting-and-leaving/2019-10-04/2020-06-23/6.0
          should "for 6 days a week (dept test 21)" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-10-04"),
              leaving_date: Date.parse("2020-06-23"),
              working_days_per_week: 6,
            )

            assert_equal "20.2", calc.formatted_full_time_part_time_days
          end
          # /days-worked-per-week/starting-and-leaving/2019-10-03/2020-05-26/1.0
          should "for 1 day a week (dept test 22)" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-10-03"),
              leaving_date: Date.parse("2020-05-26"),
              working_days_per_week: 1,
            )

            assert_equal "3.7", calc.formatted_full_time_part_time_days
          end
          # /days-worked-per-week/starting-and-leaving/2018-06-04/2018-11-13/7.0
          should "for 1 day a week (dept test 23)" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2018-06-04"),
              leaving_date: Date.parse("2018-11-13"),
              working_days_per_week: 7,
            )

            assert_equal "12.6", calc.formatted_full_time_part_time_days
          end

          #Dept Test 24 is a data entry validation to ensure leave date is after start date covered in
          #test/integration/smart_answer_flows/calculate_your_holiday_entitlement_test.rb
        end
      end
    end

    context "calculate entitlement on hours worked per week and compressed hours" do
      context "for a full leave year" do
        should "for 40 hours over 5 days per week" do
          calc = HolidayEntitlement.new(working_days_per_week: 5, hours_per_week: 40)
          assert_equal "224", calc.formatted_full_time_part_time_compressed_hours
          assert_equal [224, 0], calc.full_time_part_time_hours_and_minutes
        end

        should "for 25 hours over less than 5 days a week" do
          calc = HolidayEntitlement.new(working_days_per_week: 3, hours_per_week: 25)
          assert_equal "140", calc.formatted_full_time_part_time_compressed_hours
          assert_equal [140, 0], calc.full_time_part_time_hours_and_minutes
        end

        should "for 36 hours over more than 5 days a week" do
          calc = HolidayEntitlement.new(working_days_per_week: 6, hours_per_week: 36)
          assert_equal "168", calc.formatted_full_time_part_time_compressed_hours
          assert_equal [168, 0], calc.full_time_part_time_hours_and_minutes
        end
      end

      context "starting part way through a leave year" do
        context "for a standard year" do
          should "for 40 hours over 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-06-01"),
              leave_year_start_date: Date.parse("2019-01-01"),
              working_days_per_week: 5,
              hours_per_week: 40,
            )

            assert_equal BigDecimal("16.3333333333").round(10), calc.full_time_part_time_days.round(10)
            assert_equal BigDecimal("16.5").round(10), calc.rounded_full_time_part_time_days.round(10)
            assert_equal "132", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [132, 0], calc.full_time_part_time_hours_and_minutes
          end

          should "for 25 hours less than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-11-23"),
              leave_year_start_date: Date.parse("2020-04-01"),
              working_days_per_week: 3,
              hours_per_week: 25,
            )

            assert_equal BigDecimal("7").round(10), calc.full_time_part_time_days.round(10)
            assert_equal BigDecimal("7").round(10), calc.rounded_full_time_part_time_days.round(10)
            assert_equal "58.34", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [58, 20], calc.full_time_part_time_hours_and_minutes
          end

          should "for 36 hours more than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-11-14"),
              leave_year_start_date: Date.parse("2019-01-01"),
              working_days_per_week: 6,
              hours_per_week: 36,
            )

            assert_equal BigDecimal("4.6666666667").round(10), calc.full_time_part_time_days.round(10)
            assert_equal BigDecimal("5").round(10), calc.rounded_full_time_part_time_days.round(10)
            assert_equal "30", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [30, 0], calc.full_time_part_time_hours_and_minutes
          end
        end

        context "for a leap year" do
          should "for 40 hours over 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-06-01"),
              leave_year_start_date: Date.parse("2020-01-01"),
              working_days_per_week: 5,
              hours_per_week: 40,
            )

            assert_equal "132", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [132, 0], calc.full_time_part_time_hours_and_minutes
          end

          should "for 25 hours less than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-11-23"),
              leave_year_start_date: Date.parse("2019-04-01"),
              working_days_per_week: 3,
              hours_per_week: 25,
            )

            assert_equal "58.34", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [58, 20], calc.full_time_part_time_hours_and_minutes
          end

          should "for 36 hours more than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-11-14"),
              leave_year_start_date: Date.parse("2020-01-01"),
              working_days_per_week: 6,
              hours_per_week: 36,
            )

            assert_equal "30", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [30, 0], calc.full_time_part_time_hours_and_minutes
          end
        end
      end

      context "leaving part way through a leave year" do
        context "for a standard year" do
          should "for 40 hours over 5 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2019-06-01"),
              leave_year_start_date: Date.parse("2019-01-01"),
              working_days_per_week: 5,
              hours_per_week: 40,
            )

            assert_equal BigDecimal("224").round(10), calc.full_time_part_time_hours.round(10)
            assert_equal BigDecimal("93.2821917808").round(10), calc.pro_rated_hours.round(10)
            assert_equal "93.29", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [93, 17], calc.full_time_part_time_hours_and_minutes
          end

          should "for 25 hours less than 5 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-11-23"),
              leave_year_start_date: Date.parse("2020-04-01"),
              working_days_per_week: 3,
              hours_per_week: 25,
            )

            assert_equal BigDecimal("140").round(10), calc.full_time_part_time_hours.round(10)
            assert_equal BigDecimal("90.9041095890").round(10), calc.pro_rated_hours.round(10)
            assert_equal "90.91", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [90, 55], calc.full_time_part_time_hours_and_minutes
          end

          should "for 36 hours more than 5 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2019-08-22"),
              leave_year_start_date: Date.parse("2019-01-01"),
              working_days_per_week: 6,
              hours_per_week: 36,
            )

            assert_equal BigDecimal("168").round(10), calc.full_time_part_time_hours.round(10)
            assert_equal BigDecimal("107.7041095890").round(10), calc.pro_rated_hours.round(10)
            assert_equal "107.71", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [107, 43], calc.full_time_part_time_hours_and_minutes
          end
        end
        context "for a leap year" do
          should "for 40 hours over 5 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-06-01"),
              leave_year_start_date: Date.parse("2020-01-01"),
              working_days_per_week: 5,
              hours_per_week: 40,
            )

            assert_equal BigDecimal("224").round(10), calc.full_time_part_time_hours.round(10)
            assert_equal BigDecimal("93.6393442623").round(10), calc.pro_rated_hours.round(10)
            assert_equal "93.64", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [93, 38], calc.full_time_part_time_hours_and_minutes
          end
          should "for 25 hours less than 5 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2019-11-23"),
              leave_year_start_date: Date.parse("2019-04-01"),
              working_days_per_week: 3,
              hours_per_week: 25,
            )

            assert_equal BigDecimal("140").round(10), calc.full_time_part_time_hours.round(10)
            assert_equal BigDecimal("90.6557377049").round(10), calc.pro_rated_hours.round(10)
            assert_equal "90.66", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [90, 40], calc.full_time_part_time_hours_and_minutes
          end

          should "for 36 hours more than 5 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-08-22"),
              leave_year_start_date: Date.parse("2020-01-01"),
              working_days_per_week: 6,
              hours_per_week: 36,
            )

            assert_equal BigDecimal("168").round(10), calc.full_time_part_time_hours.round(10)
            assert_equal BigDecimal("107.8688524590").round(10), calc.pro_rated_hours.round(10)
            assert_equal "107.87", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [107, 52], calc.full_time_part_time_hours_and_minutes
          end
        end
      end

      context "starting and leaving part way through a leave year" do
        context "for a standard year" do
          should "for 40 hours over 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-01-20"),
              leaving_date: Date.parse("2019-07-18"),
              working_days_per_week: 5,
              hours_per_week: 40,
            )

            assert_equal BigDecimal("224").round(10), calc.full_time_part_time_hours.round(10)
            assert_equal BigDecimal("110.4657534247").round(10), calc.pro_rated_hours.round(10)
            assert_equal "110.47", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [110, 28], calc.full_time_part_time_hours_and_minutes
          end

          should "for 25 hours less than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2018-11-23"),
              leaving_date: Date.parse("2019-04-07"),
              working_days_per_week: 3,
              hours_per_week: 25,
            )

            assert_equal BigDecimal("140").round(10), calc.full_time_part_time_hours.round(10)
            assert_equal BigDecimal("52.1643835616").round(10), calc.pro_rated_hours.round(10)
            assert_equal "52.17", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [52, 10], calc.full_time_part_time_hours_and_minutes
          end

          should "for 36 hours more than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2018-08-22"),
              leaving_date: Date.parse("2019-07-31"),
              working_days_per_week: 6,
              hours_per_week: 36,
            )

            assert_equal BigDecimal("168").round(10), calc.full_time_part_time_hours.round(10)
            assert_equal BigDecimal("158.3342465753").round(10), calc.pro_rated_hours.round(10)
            assert_equal "158.34", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [158, 20], calc.full_time_part_time_hours_and_minutes
          end
        end
        context "for a leap year" do
          should "for 40 hours over 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-01-20"),
              leaving_date: Date.parse("2020-07-18"),
              working_days_per_week: 5,
              hours_per_week: 40,
            )

            assert_equal BigDecimal("224").round(10), calc.full_time_part_time_hours.round(10)
            assert_equal BigDecimal("110.7759562842").round(10), calc.pro_rated_hours.round(10)
            assert_equal "110.78", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [110, 47], calc.full_time_part_time_hours_and_minutes
          end
          should "for 25 hours less than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-11-23"),
              leaving_date: Date.parse("2020-04-07"),
              working_days_per_week: 3,
              hours_per_week: 25,
            )

            assert_equal BigDecimal("140").round(10), calc.full_time_part_time_hours.round(10)
            assert_equal BigDecimal("52.4043715847").round(10), calc.pro_rated_hours.round(10)
            assert_equal "52.41", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [52, 25], calc.full_time_part_time_hours_and_minutes
          end

          should "for 36 hours more than 5 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-08-22"),
              leaving_date: Date.parse("2020-07-31"),
              working_days_per_week: 6,
              hours_per_week: 36,
            )

            assert_equal BigDecimal("168").round(10), calc.full_time_part_time_hours.round(10)
            assert_equal BigDecimal("158.3606557377").round(10), calc.pro_rated_hours.round(10)
            assert_equal "158.37", calc.formatted_full_time_part_time_compressed_hours
            assert_equal [158, 22], calc.full_time_part_time_hours_and_minutes
          end
        end
      end
    end

    context "calculate entitlement on shifts worked" do
      context "for a full leave year" do
        should "for 6 hours over 14 days with 4 days per week" do
          calc = HolidayEntitlement.new(shifts_per_shift_pattern: 8,
                                        days_per_shift_pattern: 14)
          assert_equal "22.4", calc.shift_entitlement
        end
        should "for 25 hours over less than 5 days a week" do
          calc = HolidayEntitlement.new(shifts_per_shift_pattern: 7, days_per_shift_pattern: 10)
          assert_equal "27.5", calc.shift_entitlement
        end
        should "for 36 hours over more than 5 days a week" do
          calc = HolidayEntitlement.new(shifts_per_shift_pattern: 12, days_per_shift_pattern: 14)
          assert_equal "33.6", calc.shift_entitlement
        end
      end

      context "for starting part way through a leave year" do
        context "for a standard year" do
          should "for 4 shifts per week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-06-01"),
              leave_year_start_date: Date.parse("2019-01-01"),
              shifts_per_shift_pattern: 8,
              days_per_shift_pattern: 14,
              )

            assert_equal "13.5", calc.shift_entitlement
          end

          should "for 4.9 shifts per week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-11-23"),
              leave_year_start_date: Date.parse("2020-04-01"),
              shifts_per_shift_pattern: 7,
              days_per_shift_pattern: 10,
              )

            assert_equal "11.5", calc.shift_entitlement
          end

          should "for 6 shifts per week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-11-14"),
              leave_year_start_date: Date.parse("2019-01-01"),
              shifts_per_shift_pattern: 12,
              days_per_shift_pattern: 14,
              )

            assert_equal "5", calc.shift_entitlement
          end
        end

        context "for a leap year" do
          should "for 4 shifts per week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-06-01"),
              leave_year_start_date: Date.parse("2020-01-01"),
              shifts_per_shift_pattern: 8,
              days_per_shift_pattern: 14,
              )

            assert_equal "13.5", calc.shift_entitlement
          end

          should "for 4.9 shifts per week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-11-23"),
              leave_year_start_date: Date.parse("2019-04-01"),
              shifts_per_shift_pattern: 7,
              days_per_shift_pattern: 10,
              )

            assert_equal "11.5", calc.shift_entitlement
          end

          should "for 6 shifts per week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-11-14"),
              leave_year_start_date: Date.parse("2020-01-01"),
              shifts_per_shift_pattern: 12,
              days_per_shift_pattern: 14,
              )

            assert_equal "5", calc.shift_entitlement
          end
        end
      end

      context "leaving part way through a leave year" do
        context "for a standard year" do
          should "for 6 hours over 4 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2019-06-01"),
              leave_year_start_date: Date.parse("2019-01-01"),
              shifts_per_shift_pattern: 8,
              days_per_shift_pattern: 14,
              )

            assert_equal "9.33", calc.shift_entitlement
          end

          should "for 25 hours over 4.9 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-11-23"),
              leave_year_start_date: Date.parse("2020-04-01"),
              shifts_per_shift_pattern: 7,
              days_per_shift_pattern: 10,
            )

            assert_equal "17.82", calc.shift_entitlement
          end

          should "for 36 hours over 6 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2019-11-14"),
              leave_year_start_date: Date.parse("2019-01-01"),
              shifts_per_shift_pattern: 12,
              days_per_shift_pattern: 14,
            )

            assert_equal "24.40", calc.shift_entitlement
          end
        end
        context "for a leap year" do
          should "for 6 hours over 4 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-06-01"),
              leave_year_start_date: Date.parse("2020-01-01"),
              shifts_per_shift_pattern: 8,
              days_per_shift_pattern: 14,
            )

            assert_equal "9.37", calc.shift_entitlement
          end

          should "for 25 hours over 4.9 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2019-11-23"),
              leave_year_start_date: Date.parse("2019-04-01"),
              shifts_per_shift_pattern: 7,
              days_per_shift_pattern: 10,
            )

            assert_equal "17.77", calc.shift_entitlement
          end

          should "for 36 hours over 6 days a week" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-11-14"),
              leave_year_start_date: Date.parse("2020-01-01"),
              shifts_per_shift_pattern: 12,
              days_per_shift_pattern: 14,
            )

            assert_equal "24.41", calc.shift_entitlement
          end
        end
      end

      context "starting and leaving part way through a leave year" do
        context "for a standard year" do
          should "for 6 hours over 4 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-01-20"),
              leaving_date: Date.parse("2019-07-18"),
              shifts_per_shift_pattern: 8,
              days_per_shift_pattern: 14,
            )

            assert_equal "11.05", calc.shift_entitlement
          end

          should "for 25 hours over 4.9 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-11-23"),
              leaving_date: Date.parse("2021-04-07"),
              shifts_per_shift_pattern: 7,
              days_per_shift_pattern: 10,
            )

            assert_equal "10.23", calc.shift_entitlement
          end

          should "for 36 hours over 6 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-08-22"),
              leaving_date: Date.parse("2021-07-31"),
              shifts_per_shift_pattern: 12,
              days_per_shift_pattern: 14,
            )

            assert_equal "26.39", calc.shift_entitlement
          end
        end

        context "for a leap year" do
          should "for 6 hours over 4 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-01-20"),
              leaving_date: Date.parse("2020-07-18"),
              shifts_per_shift_pattern: 8,
              days_per_shift_pattern: 14,
            )

            assert_equal "11.08", calc.shift_entitlement
          end

          should "for 25 hours over 4.9 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-11-23"),
              leaving_date: Date.parse("2020-04-07"),
              shifts_per_shift_pattern: 7,
              days_per_shift_pattern: 10,
            )

            assert_equal "10.28", calc.shift_entitlement
          end

          should "for 36 hours over 6 days a week" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-08-22"),
              leaving_date: Date.parse("2020-07-31"),
              shifts_per_shift_pattern: 12,
              days_per_shift_pattern: 14,
            )

            assert_equal "26.40", calc.shift_entitlement
          end
        end
      end
    end

    context "calculate entitlement on irregular hours" do
      context "for a full leave year" do
        # /irregular-hours/full-year
        should "return 5.6 weeks (dept test 1)" do
          calc = HolidayEntitlement.new
          assert_equal "5.6", calc.formatted_full_time_part_time_weeks
        end
      end

      context "starting part way through a leave year" do
        context "for a standard year" do
          should "return 3.27 weeks when start_date is 2019-06-01 and leave_year_start_date is 2019-01-01" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-06-01"),
              leave_year_start_date: Date.parse("2019-01-01"),
            )

            assert_equal BigDecimal("0.5833333333").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("3.2666666667").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "3.27", calc.formatted_full_time_part_time_weeks
          end

          should "return 2.34 weeks when start_date is 2020-11-23 and leave_year_start_date is 2020-04-01" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-11-23"),
              leave_year_start_date: Date.parse("2020-04-01"),
            )

            assert_equal BigDecimal("0.4166666667").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("2.3333333333").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "2.34", calc.formatted_full_time_part_time_weeks
          end

          should "return 0.94 weeks when start_date is 2019-11-14 and leave_year_start_date is 2019-01-01" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-11-14"),
              leave_year_start_date: Date.parse("2019-01-01"),
            )

            assert_equal BigDecimal("0.1666666667").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("0.9333333333").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "0.94", calc.formatted_full_time_part_time_weeks
          end
        end

        context "for a leap year" do
          should "return 3.27 weeks when start_date is 2020-06-01 and leave_year_start_date is 2020-01-01" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-06-01"),
              leave_year_start_date: Date.parse("2020-01-01"),
            )

            assert_equal BigDecimal("0.5833333333").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("3.2666666667").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "3.27", calc.formatted_full_time_part_time_weeks
          end

          should "return 2.34 weeks when start_date is 2019-11-23 and leave_year_start_date is 2019-04-01" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-11-23"),
              leave_year_start_date: Date.parse("2019-04-01"),
            )

            assert_equal BigDecimal("0.4166666667").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("2.3333333333").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "2.34", calc.formatted_full_time_part_time_weeks
          end

          should "return 0.94 weeks when start_date is 2020-11-14 and leave_year_start_date is 2020-01-01" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-11-14"),
              leave_year_start_date: Date.parse("2020-01-01"),
            )

            assert_equal BigDecimal("0.1666666667").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("0.9333333333").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "0.94", calc.formatted_full_time_part_time_weeks
          end
        end

        context "for department test data" do
          # /irregular-hours/starting/2020-05-20/2019-10-01
          should "dept test 2" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-05-20"),
              leave_year_start_date: Date.parse("2019-10-01"),
            )

            assert_equal "2.34", calc.formatted_full_time_part_time_weeks
          end
          # /irregular-hours/starting/2020-09-07/2020-01-01
          should "dept test 3" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-09-07"),
              leave_year_start_date: Date.parse("2020-01-01"),
            )

            assert_equal "1.87", calc.formatted_full_time_part_time_weeks
          end
          # /irregular-hours/starting/2018-12-14/2018-03-01
          should "dept test 4" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2018-12-14"),
              leave_year_start_date: Date.parse("2018-03-01"),
            )

            assert_equal "1.40", calc.formatted_full_time_part_time_weeks
          end
          # /irregular-hours/starting/2018-08-11/2019-01-01
          should "dept test 5" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2018-08-11"),
              leave_year_start_date: Date.parse("2019-01-01"),
            )

            assert_equal "2.34", calc.formatted_full_time_part_time_weeks
          end
          # /irregular-hours/starting/2020-06-15/2019-10-01
          should "dept test 6" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-06-15"),
              leave_year_start_date: Date.parse("2019-10-01"),
            )

            assert_equal "1.87", calc.formatted_full_time_part_time_weeks
          end
          # /irregular-hours/starting/2018-05-01/2018-02-26
          should "dept test 7" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2018-05-01"),
              leave_year_start_date: Date.parse("2018-02-26"),
            )

            assert_equal "4.67", calc.formatted_full_time_part_time_weeks
          end
          # /irregular-hours/starting/2019-09-07/2019-07-05
          should "dept test 8" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-09-07"),
              leave_year_start_date: Date.parse("2019-07-05"),
            )

            assert_equal "4.67", calc.formatted_full_time_part_time_weeks
          end
        end
      end

      context "leaving part way through a leave year" do
        context "for a standard year" do
          should "return 2.34 weeks when leaving_date is 2019-06-01 and leave_year_start_date is 2019-01-01" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2019-06-01"),
              leave_year_start_date: Date.parse("2019-01-01"),
            )

            assert_equal BigDecimal("0.4164383562").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("2.3320547945").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "2.34", calc.formatted_full_time_part_time_weeks
          end

          should "return 3.64 weeks when leaving_date is 2020-11-23 and leave_year_start_date is 2020-04-01" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-11-23"),
              leave_year_start_date: Date.parse("2020-04-01"),
            )

            assert_equal BigDecimal("0.6493150685").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("3.6361643836").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "3.64", calc.formatted_full_time_part_time_weeks
          end

          should "return 3.60 weeks when leaving_date is 2019-08-22 and leave_year_start_date is 2019-01-01" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2019-08-22"),
              leave_year_start_date: Date.parse("2019-01-01"),
            )

            assert_equal BigDecimal("0.6410958904").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("3.5901369863").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "3.60", calc.formatted_full_time_part_time_weeks
          end
        end

        context "for a leap year" do
          should "return 2.35 weeks when leaving_date is 2020-06-01 and leave_year_start_date is 2020-01-01" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-06-01"),
              leave_year_start_date: Date.parse("2020-01-01"),
            )

            assert_equal BigDecimal("0.4180327869").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("2.3409836066").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "2.35", calc.formatted_full_time_part_time_weeks
          end

          should "return 3.63 weeks when leaving_date is 2019-11-23 and leave_year_start_date is 2019-04-01" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2019-11-23"),
              leave_year_start_date: Date.parse("2019-04-01"),
            )

            assert_equal BigDecimal("0.6475409836").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("3.6262295082").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "3.63", calc.formatted_full_time_part_time_weeks
          end

          should "return 3.60 weeks when leaving_date is 2020-08-22 and leave_year_start_date is 2020-01-01" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-08-22"),
              leave_year_start_date: Date.parse("2020-01-01"),
            )

            assert_equal BigDecimal("0.6420765027").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("3.5956284153").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "3.60", calc.formatted_full_time_part_time_weeks
          end
        end

        context "for department test data" do
          # /irregular-hours/leaving/2018-08-29/2018-03-01
          should "dept test 9" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2018-08-29"),
              leave_year_start_date: Date.parse("2018-03-01"),
            )

            assert_equal "2.80", calc.formatted_full_time_part_time_weeks
          end
          # /irregular-hours/leaving/2020-06-18/2010-12-01
          should "dept test 10" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-06-18"),
              leave_year_start_date: Date.parse("2010-12-01"),
            )

            assert_equal "3.08", calc.formatted_full_time_part_time_weeks
          end
          # /irregular-hours/leaving/2019-09-20/2019-03-01
          should "dept test 11" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2019-09-20"),
              leave_year_start_date: Date.parse("2019-03-01"),
            )

            assert_equal "3.13", calc.formatted_full_time_part_time_weeks
          end
          # /irregular-hours/leaving/2019-06-17/2018-10-01
          should "dept test 12" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2019-06-17"),
              leave_year_start_date: Date.parse("2018-10-01"),
            )

            assert_equal "3.99", calc.formatted_full_time_part_time_weeks
          end
          # /irregular-hours/leaving/2020-09-20/2020-04-01
          should "dept test 13" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-09-20"),
              leave_year_start_date: Date.parse("2020-04-01"),
            )

            assert_equal "2.66", calc.formatted_full_time_part_time_weeks
          end
          # /irregular-hours/leaving/2020-05-07/2020-03-07
          should "dept test 14" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-05-07"),
              leave_year_start_date: Date.parse("2020-03-07"),
            )

            assert_equal "0.96", calc.formatted_full_time_part_time_weeks
          end

          #Dept Test 15 is a data entry validation to ensure leaving date is before leave year starts
          #covered in test/integration/smart_answer_flows/calculate_your_holiday_entitlement_test.rb
        end
      end

      context "starting and leaving part way through a leave year" do
        context "for a standard year" do
          should "return 2.77 weeks when start_date is 2019-01-20 and leaving_date is 2019-07-18" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-01-20"),
              leaving_date: Date.parse("2019-07-18"),
            )

            assert_equal BigDecimal("0.4931506849").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("2.7616438356").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "2.77", calc.formatted_full_time_part_time_weeks
          end

          should "return 2.09 weeks when start_date is 2020-11-23 and leaving_date is 2021-04-07" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-11-23"),
              leaving_date: Date.parse("2021-04-07"),
            )

            assert_equal BigDecimal("0.3726027397").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("2.0865753425").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "2.09", calc.formatted_full_time_part_time_weeks
          end

          should "return 5.28 weeks when start_date is 2020-08-22 and leaving_date is 2021-07-31" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-08-22"),
              leaving_date: Date.parse("2021-07-31"),
            )

            assert_equal BigDecimal("0.9424657534").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("5.2778082192").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "5.28", calc.formatted_full_time_part_time_weeks
          end
        end

        context "for a leap year" do
          should "return 2.77 weeks when start_date is 2020-01-20 and leaving_date is 2020-07-18" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-01-20"),
              leaving_date: Date.parse("2020-07-18"),
            )

            assert_equal BigDecimal("0.4945355191").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("2.7693989071").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "2.77", calc.formatted_full_time_part_time_weeks
          end

          should "return 2.10 weeks when start_date is 2019-11-23 and leaving_date is 2020-04-07" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-11-23"),
              leaving_date: Date.parse("2020-04-07"),
            )

            assert_equal BigDecimal("0.3743169399").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("2.0961748634").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "2.10", calc.formatted_full_time_part_time_weeks
          end

          should "return 5.28 weeks when start_date is 2019-08-22 and leaving_date is 2020-07-31" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-08-22"),
              leaving_date: Date.parse("2020-07-31"),
            )

            assert_equal BigDecimal("0.9426229508").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("5.2786885246").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "5.28", calc.formatted_full_time_part_time_weeks
          end
        end

        context "for department test data" do
          # /irregular-hours/starting-and-leaving/2019-10-02/2020-06-30
          should "dept test 16" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-10-02"),
              leaving_date: Date.parse("2020-06-30"),
            )

            assert_equal "4.18", calc.formatted_full_time_part_time_weeks
          end
          # /irregular-hours/starting-and-leaving/2020-02-02/2020-11-24
          should "dept test 17" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-02-02"),
              leaving_date: Date.parse("2020-11-24"),
            )

            assert_equal "4.55", calc.formatted_full_time_part_time_weeks
          end
          # /irregular-hours/starting-and-leaving/2020-06-23/2020-08-10
          should "dept test 18" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-06-23"),
              leaving_date: Date.parse("2020-08-10"),
            )

            assert_equal "0.76", calc.formatted_full_time_part_time_weeks
          end
          # /irregular-hours/starting-and-leaving/2018-01-16/2018-07-12
          should "dept test 19" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2018-01-16"),
              leaving_date: Date.parse("2018-07-12"),
            )

            assert_equal "2.74", calc.formatted_full_time_part_time_weeks
          end
          # /irregular-hours/starting-and-leaving/2019-06-22/2020-03-03
          should "dept test 20" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-06-22"),
              leaving_date: Date.parse("2020-03-03"),
            )

            assert_equal "3.92", calc.formatted_full_time_part_time_weeks
          end
          # /irregular-hours/starting-and-leaving/2018-06-09/2019-02-01
          should "dept test 21" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2018-06-09"),
              leaving_date: Date.parse("2019-02-01"),
            )

            assert_equal "3.66", calc.formatted_full_time_part_time_weeks
          end

          #Dept Test 22 is a data entry validation to ensure leaving date is before leave year starts
          #covered in test/integration/smart_answer_flows/calculate_your_holiday_entitlement_test.rb
        end
      end
    end

    context "calculate entitlement on annualised hours" do
      context "for a full leave year" do
        # /irregular-hours/full-year
        should "return 5.6 weeks (dept test 1)" do
          calc = HolidayEntitlement.new
          assert_equal "5.6", calc.formatted_full_time_part_time_weeks
        end
      end

      context "starting part way through a leave year" do
        context "for a standard year" do
          should "return 3.27 weeks when start_date is 2019-06-01 and leave_year_start_date is 2019-01-01" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-06-01"),
              leave_year_start_date: Date.parse("2019-01-01"),
            )

            assert_equal BigDecimal("0.5833333333").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("3.2666666667").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "3.27", calc.formatted_full_time_part_time_weeks
          end

          should "return 2.34 weeks when start_date is 2020-11-23 and leave_year_start_date is 2020-04-01" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-11-23"),
              leave_year_start_date: Date.parse("2020-04-01"),
            )

            assert_equal BigDecimal("0.4166666667").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("2.3333333333").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "2.34", calc.formatted_full_time_part_time_weeks
          end

          should "return 0.94 weeks when start_date is 2019-11-14 and leave_year_start_date is 2019-01-01" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-11-14"),
              leave_year_start_date: Date.parse("2019-01-01"),
            )

            assert_equal BigDecimal("0.1666666667").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("0.9333333333").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "0.94", calc.formatted_full_time_part_time_weeks
          end
        end

        context "for a leap year" do
          should "return 3.27 weeks when start_date is 2020-06-01 and leave_year_start_date is 2020-01-01" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-06-01"),
              leave_year_start_date: Date.parse("2020-01-01"),
            )

            assert_equal BigDecimal("0.5833333333").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("3.2666666667").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "3.27", calc.formatted_full_time_part_time_weeks
          end

          should "return 2.34 weeks when start_date is 2019-11-23 and leave_year_start_date is 2019-04-01" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-11-23"),
              leave_year_start_date: Date.parse("2019-04-01"),
            )

            assert_equal BigDecimal("0.4166666667").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("2.3333333333").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "2.34", calc.formatted_full_time_part_time_weeks
          end

          should "return 0.94 weeks when start_date is 2020-11-14 and leave_year_start_date is 2020-01-01" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-11-14"),
              leave_year_start_date: Date.parse("2020-01-01"),
            )

            assert_equal BigDecimal("0.1666666667").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("0.9333333333").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "0.94", calc.formatted_full_time_part_time_weeks
          end
        end

        context "for department test data" do
          # /annualised-hours/starting/2020-05-29/2019-12-01
          should "dept test 2" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-05-29"),
              leave_year_start_date: Date.parse("2019-12-01"),
            )

            assert_equal "3.27", calc.formatted_full_time_part_time_weeks
          end
          # /annualised-hours/starting/2020-09-03/2019-12-01
          should "dept test 3" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-09-03"),
              leave_year_start_date: Date.parse("2019-12-01"),
            )

            assert_equal "1.40", calc.formatted_full_time_part_time_weeks
          end
          # /annualised-hours/starting/2019-03-01/2018-10-01
          should "dept test 4" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-03-01"),
              leave_year_start_date: Date.parse("2018-10-01"),
            )

            assert_equal "3.27", calc.formatted_full_time_part_time_weeks
          end
          # /annualised-hours/starting/2020-06-05/2020-01-01
          should "dept test 5" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-06-05"),
              leave_year_start_date: Date.parse("2020-01-01"),
            )

            assert_equal "3.27", calc.formatted_full_time_part_time_weeks
          end
          # /annualised-hours/starting/2019-04-07/2019-11-01
          should "dept test 6" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-04-07"),
              leave_year_start_date: Date.parse("2019-11-01"),
            )

            assert_equal "3.27", calc.formatted_full_time_part_time_weeks
          end
          # /annualised-hours/starting/2019-09-23/2018-08-14
          should "dept test 7" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-09-23"),
              leave_year_start_date: Date.parse("2018-08-14"),
            )

            assert_equal "5.14", calc.formatted_full_time_part_time_weeks
          end
          # /annualised-hours/starting/2020-02-16/2019-04-02
          should "dept test 8" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-02-16"),
              leave_year_start_date: Date.parse("2019-04-02"),
            )

            assert_equal "0.94", calc.formatted_full_time_part_time_weeks
          end
        end
      end

      context "leaving part way through a leave year" do
        context "for a standard year" do
          should "return 2.34 weeks when leaving_date is 2019-06-01 and leave_year_start_date is 2019-01-01" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2019-06-01"),
              leave_year_start_date: Date.parse("2019-01-01"),
            )

            assert_equal BigDecimal("0.4164383562").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("2.3320547945").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "2.34", calc.formatted_full_time_part_time_weeks
          end

          should "return 3.64 weeks when leaving_date is 2020-11-23 and leave_year_start_date is 2020-04-01" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-11-23"),
              leave_year_start_date: Date.parse("2020-04-01"),
            )

            assert_equal BigDecimal("0.6493150685").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("3.6361643836").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "3.64", calc.formatted_full_time_part_time_weeks
          end

          should "return 3.60 weeks when leaving_date is 2019-08-22 and leave_year_start_date is 2019-01-01" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2019-08-22"),
              leave_year_start_date: Date.parse("2019-01-01"),
            )

            assert_equal BigDecimal("0.6410958904").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("3.5901369863").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "3.60", calc.formatted_full_time_part_time_weeks
          end
        end

        context "for a leap year" do
          should "return 2.35 weeks when leaving_date is 2020-06-01 and leave_year_start_date is 2020-01-01" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-06-01"),
              leave_year_start_date: Date.parse("2020-01-01"),
            )

            assert_equal BigDecimal("0.4180327869").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("2.3409836066").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "2.35", calc.formatted_full_time_part_time_weeks
          end

          should "return 3.63 weeks when leaving_date is 2019-11-23 and leave_year_start_date is 2019-04-01" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2019-11-23"),
              leave_year_start_date: Date.parse("2019-04-01"),
            )

            assert_equal BigDecimal("0.6475409836").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("3.6262295082").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "3.63", calc.formatted_full_time_part_time_weeks
          end

          should "return 3.60 weeks when leaving_date is 2020-08-22 and leave_year_start_date is 2020-01-01" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-08-22"),
              leave_year_start_date: Date.parse("2020-01-01"),
            )

            assert_equal BigDecimal("0.6420765027").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("3.5956284153").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "3.60", calc.formatted_full_time_part_time_weeks
          end
        end

        context "for department test data" do
         # /annualised-hours/leaving/2020-06-24/2019-12-01
          should "dept test 9" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-06-24"),
              leave_year_start_date: Date.parse("2019-12-01"),
            )

            assert_equal "3.17", calc.formatted_full_time_part_time_weeks
          end

          # department test 10 is data validation to ensure leaving date is after leave year start
          # this is covered in  test/integration/smart_answer_flows/calculate_your_holiday_entitlement_test.rb

          # /annualised-hours/leaving/2018-12-30/2018-06-01
          should "dept test 11" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2018-12-30"),
              leave_year_start_date: Date.parse("2018-06-01"),
            )

            assert_equal "3.27", calc.formatted_full_time_part_time_weeks
          end
          # /annualised-hours/leaving/2020-12-13/2020-08-01
          should "dept test 12" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-12-13"),
              leave_year_start_date: Date.parse("2020-08-01"),
            )

            assert_equal "2.08", calc.formatted_full_time_part_time_weeks
          end
          # /annualised-hours/leaving/2020-08-31/2020-01-01
          should "dept test 13" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-08-31"),
              leave_year_start_date: Date.parse("2020-01-01"),
            )

            assert_equal "3.74", calc.formatted_full_time_part_time_weeks
          end
          # /annualised-hours/leaving/2019-11-07/2019-08-05
          should "dept test 14" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2019-11-07"),
              leave_year_start_date: Date.parse("2019-08-05"),
            )

            assert_equal "1.46", calc.formatted_full_time_part_time_weeks
          end
          # /annualised-hours/leaving/2020-06-18/2019-10-20
          should "dept test 15" do
            calc = HolidayEntitlement.new(
              leaving_date: Date.parse("2020-06-18"),
              leave_year_start_date: Date.parse("2019-10-20"),
            )

            assert_equal "3.72", calc.formatted_full_time_part_time_weeks
          end
        end
      end

      context "starting and leaving part way through a leave year" do
        context "for a standard year" do
          should "return 2.77 weeks when start_date is 2019-01-20 and leaving_date is 2019-07-18" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-01-20"),
              leaving_date: Date.parse("2019-07-18"),
            )

            assert_equal BigDecimal("0.4931506849").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("2.7616438356").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "2.77", calc.formatted_full_time_part_time_weeks
          end

          should "return 2.09 weeks when start_date is 2020-11-23 and leaving_date is 2021-04-07" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-11-23"),
              leaving_date: Date.parse("2021-04-07"),
            )

            assert_equal BigDecimal("0.3726027397").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("2.0865753425").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "2.09", calc.formatted_full_time_part_time_weeks
          end

          should "return 5.28 weeks when start_date is 2020-08-22 and leaving_date is 2021-07-31" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-08-22"),
              leaving_date: Date.parse("2021-07-31"),
            )

            assert_equal BigDecimal("0.9424657534").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("5.2778082192").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "5.28", calc.formatted_full_time_part_time_weeks
          end
        end

        context "for a leap year" do
          should "return 2.77 weeks when start_date is 2020-01-20 and leaving_date is 2020-07-18" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-01-20"),
              leaving_date: Date.parse("2020-07-18"),
            )

            assert_equal BigDecimal("0.4945355191").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("2.7693989071").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "2.77", calc.formatted_full_time_part_time_weeks
          end

          should "return 2.10 weeks when start_date is 2019-11-23 and leaving_date is 2020-04-07" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-11-23"),
              leaving_date: Date.parse("2020-04-07"),
            )

            assert_equal BigDecimal("0.3743169399").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("2.0961748634").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "2.10", calc.formatted_full_time_part_time_weeks
          end

          should "return 5.28 weeks when start_date is 2019-08-22 and leaving_date is 2020-07-31" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-08-22"),
              leaving_date: Date.parse("2020-07-31"),
            )

            assert_equal BigDecimal("0.9426229508").round(10), calc.fraction_of_year.round(10)
            assert_equal BigDecimal("5.2786885246").round(10), calc.full_time_part_time_weeks.round(10)
            assert_equal "5.28", calc.formatted_full_time_part_time_weeks
          end
        end

        context "for department test data" do
          # /annualised-hours/starting-and-leaving/2019-01-12/2019-03-27
          should "dept test 16" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-01-12"),
              leaving_date: Date.parse("2019-03-27"),
            )

            assert_equal "1.16", calc.formatted_full_time_part_time_weeks
          end
          # /annualised-hours/starting-and-leaving/2018-12-10/2019-05-14
          should "dept test 17" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2018-12-10"),
              leaving_date: Date.parse("2019-05-14"),
            )

            assert_equal "2.40", calc.formatted_full_time_part_time_weeks
          end
          # /annualised-hours/starting-and-leaving/2018-08-30/2019-05-27
          should "dept test 18" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2018-08-30"),
              leaving_date: Date.parse("2019-05-27"),
            )

            assert_equal "4.16", calc.formatted_full_time_part_time_weeks
          end
          # /annualised-hours/starting-and-leaving/2019-10-07/2019-12-20
          should "dept test 19" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-10-07"),
              leaving_date: Date.parse("2019-12-20"),
            )

            assert_equal "1.15", calc.formatted_full_time_part_time_weeks
          end
          # /annualised-hours/starting-and-leaving/2019-07-29/2020-05-23
          should "dept test 20" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-07-29"),
              leaving_date: Date.parse("2020-05-23"),
            )

            assert_equal "4.60", calc.formatted_full_time_part_time_weeks
          end
          # /annualised-hours/starting-and-leaving/2020-01-01/2020-06-01
          should "dept test 21" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2020-01-01"),
              leaving_date: Date.parse("2020-06-01"),
            )

            assert_equal "2.35", calc.formatted_full_time_part_time_weeks
          end
          # /annualised-hours/starting-and-leaving/2019-04-06/2020-02-03
          should "dept test 22" do
            calc = HolidayEntitlement.new(
              start_date: Date.parse("2019-04-06"),
              leaving_date: Date.parse("2020-02-03"),
            )

            assert_equal "4.66", calc.formatted_full_time_part_time_weeks
          end
        end
      end
    end
  end
end
