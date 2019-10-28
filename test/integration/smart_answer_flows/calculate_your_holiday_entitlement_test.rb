require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/calculate-your-holiday-entitlement"

class CalculateYourHolidayEntitlementTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::CalculateYourHolidayEntitlementFlow
    @stubbed_calculator = SmartAnswer::Calculators::HolidayEntitlement.new
  end

  should "ask what the basis of the calculation is" do
    assert_current_node :basis_of_calculation?
  end

  context "for hours worked per week" do
    setup do
      add_response "hours-worked-per-week"
    end
    should "ask the time period for the calculation" do
      assert_current_node :calculation_period?
    end
    context "answer full leave year" do
      setup do
        add_response "full-year"
      end
      should "ask the number of hours worked per week" do
        assert_current_node :how_many_hours_per_week?
      end
      context "answer 32 hours" do
        setup do
          add_response "32"
        end
        should "ask the number of days worked per week" do
          assert_current_node :how_many_days_per_week_for_hours?
        end
        context "answer 5 days" do
          setup do
            add_response "5"
          end
          should "calculate the holiday entitlement" do
            SmartAnswer::Calculators::HolidayEntitlement
              .expects(:new)
              .with(
                hours_per_week: 32.0,
                working_days_per_week: 5.0,
                start_date: nil,
                leaving_date: nil,
                leave_year_start_date: nil,
              ).returns(@stubbed_calculator)
            @stubbed_calculator.expects(:full_time_part_time_hours).returns(179.2)

            assert_current_node :hours_per_week_done
            assert_state_variable "holiday_entitlement_hours", 179
            assert_state_variable "holiday_entitlement_minutes", 12
            assert_current_node :hours_per_week_done
          end
        end
      end
    end
    context "answer starting part way through the leave year" do
      setup do
        add_response "starting"
      end
      should "ask for the employment start date" do
        assert_current_node :what_is_your_starting_date?
      end
      context "answer June 15th this year" do
        setup do
          add_response "#{Date.today.year}-06-15"
        end
        should "ask when the leave year started" do
          assert_current_node :when_does_your_leave_year_start?
        end
        context "answer Jan 1st this year" do
          setup do
            add_response "#{Date.today.year}-01-01"
          end
          should "ask the number of hours worked per week" do
            assert_current_node :how_many_hours_per_week?
          end
          context "answer 37 hours" do
            setup do
              add_response "37"
            end
            context "answer 5 days" do
              setup do
                add_response "5"
              end
              should "calculate the holiday entitlement" do
                SmartAnswer::Calculators::HolidayEntitlement.
                  expects(:new).
                  with(
                    hours_per_week: 37.0,
                    working_days_per_week: 5,
                    start_date: Date.parse("#{Date.today.year}-06-15"),
                    leaving_date: nil,
                    leave_year_start_date: Date.parse("#{Date.today.year}-01-01"),
                  ).
                  returns(@stubbed_calculator)
                @stubbed_calculator.expects(:full_time_part_time_hours).returns(79.5)

                assert_current_node :hours_per_week_done
                assert_state_variable "holiday_entitlement_hours", 79
                assert_state_variable "holiday_entitlement_minutes", 30
              end
            end
          end
        end
      end
    end

    context "answer leaving part way through the leave year" do
      setup do
        add_response "leaving"
      end
      should "ask for the employment end date" do
        assert_current_node :what_is_your_leaving_date?
      end
      context "answer 06-15" do
        setup do
          add_response "#{Date.today.year}-06-15"
        end
        should "ask when the leave year started" do
          assert_current_node :when_does_your_leave_year_start?
        end
        context "answer 01-01" do
          setup do
            add_response "#{Date.today.year}-01-01"
          end
          should "ask the number of hours worked per week" do
            assert_current_node :how_many_hours_per_week?
          end
          context "answer 26.5 hours" do
            setup do
              add_response "26.5"
            end
            context "answer 5 days" do
              setup do
                add_response "5"
              end
              should "calculate the holiday entitlement" do
                SmartAnswer::Calculators::HolidayEntitlement.
                  expects(:new).
                  with(
                    hours_per_week: 26.5,
                    working_days_per_week: 5,
                    start_date: nil,
                    leaving_date: Date.parse("#{Date.today.year}-06-15"),
                    leave_year_start_date: Date.parse("#{Date.today.year}-01-01"),
                  ).
                  returns(@stubbed_calculator)
                @stubbed_calculator.expects(:full_time_part_time_hours).returns(19.75)

                assert_current_node :hours_per_week_done
                assert_state_variable "holiday_entitlement_hours", 19
                assert_state_variable "holiday_entitlement_minutes", 45
              end
            end
          end
        end
      end
    end

    context "starting and leaving within a leave year" do
      setup do
        add_response "starting-and-leaving"
      end
      should "ask what was the employment start date" do
        assert_current_node :what_is_your_starting_date?
      end
      context "add employment start date" do
        setup do
          add_response "#{Date.today.year}-07-14"
        end
        should "ask what date employment finished" do
          assert_current_node :what_is_your_leaving_date?
        end
        context "add employment end date" do
          setup do
            add_response "#{Date.today.year}-10-14"
          end
          should "ask you how many hours worked per week" do
            assert_current_node :how_many_hours_per_week?
          end
          context "add hours worker per week" do
            setup do
              add_response "37"
            end
            should "ask you how many days worked per week" do
              assert_current_node :how_many_days_per_week_for_hours?
            end
            should "calculate and be done part year when 5 days" do
              SmartAnswer::Calculators::HolidayEntitlement
                .expects(:new)
                .with(
                  hours_per_week: 37,
                  working_days_per_week: 5,
                  start_date: Date.parse("#{Date.today.year}-07-14"),
                  leaving_date: Date.parse("#{Date.today.year}-10-14"),
                  leave_year_start_date: nil,
                ).returns(@stubbed_calculator)
              @stubbed_calculator.expects(:full_time_part_time_hours).returns(79.5)

              add_response "5"
              assert_current_node :hours_per_week_done
              assert_state_variable "holiday_entitlement_hours", 79
              assert_state_variable "holiday_entitlement_minutes", 30
            end
          end
        end
      end
    end
  end # hours-worked-per-week

  context "compressed hours" do
    setup do
      add_response "compressed-hours"
    end

    should "ask how many hours per week you work" do
      assert_current_node :compressed_hours_how_many_hours_per_week?
    end

    should "be invalid if <= 0 hours per week" do
      add_response "0.0"
      assert_current_node :compressed_hours_how_many_hours_per_week?, error: true
    end

    should "be invalid if more than 168 hours per week" do
      add_response "168.1"
      assert_current_node :compressed_hours_how_many_hours_per_week?, error: true
    end

    should "ask how many days per week you work" do
      add_response "20"
      assert_current_node :compressed_hours_how_many_days_per_week?
    end

    should "be invalid with less than 1 day per week" do
      add_response "20"
      add_response "0"
      assert_current_node :compressed_hours_how_many_days_per_week?, error: true
    end

    should "be invalid with more than 7 days per week" do
      add_response "20"
      add_response "8"
      assert_current_node :compressed_hours_how_many_days_per_week?, error: true
    end

    should "calculate and be done with hours and days entered" do
      SmartAnswer::Calculators::HolidayEntitlement
        .expects(:new)
        .with(hours_per_week: 20.5, working_days_per_week: 3)
        .returns(@stubbed_calculator)
      @stubbed_calculator.expects(:compressed_hours_entitlement).at_least_once.returns(["formatted hours", "formatted minutes"])
      @stubbed_calculator.expects(:compressed_hours_daily_average).at_least_once.returns(["formatted daily hours", "formatted daily minutes"])

      add_response "20.5"
      add_response "3"
      assert_current_node :compressed_hours_done
      assert_state_variable :hours_per_week, 20.5
      assert_state_variable :working_days_per_week, 3
      assert_state_variable :holiday_entitlement_hours, "formatted hours"
      assert_state_variable :holiday_entitlement_minutes, "formatted minutes"
      assert_state_variable :hours_daily, "formatted daily hours"
      assert_state_variable :minutes_daily, "formatted daily minutes"
    end
  end # compressed hours

  context "shift worker" do
    setup do
      add_response "shift-worker"
    end

    should "ask how long you're working in shifts" do
      assert_current_node :shift_worker_basis?
    end

    context "full year" do
      setup do
        add_response "full-year"
      end

      should "ask how many hours in each shift" do
        assert_current_node :shift_worker_hours_per_shift?
      end

      should "ask how many shifts per shift pattern" do
        add_response "7.5"
        assert_current_node :shift_worker_shifts_per_shift_pattern?
      end

      should "ask how many days per shift pattern" do
        add_response "7.5"
        add_response "4"
        assert_current_node :shift_worker_days_per_shift_pattern?
      end

      should "calculate and be done when all entered" do
        add_response "7.25"
        add_response "4"
        add_response "8"

        SmartAnswer::Calculators::HolidayEntitlement
          .expects(:new)
          .with(
            start_date: nil,
            leaving_date: nil,
            leave_year_start_date: nil,
            hours_per_shift: 7.25,
            shifts_per_shift_pattern: 4,
            days_per_shift_pattern: 8,
          ).returns(@stubbed_calculator)
        @stubbed_calculator.expects(:formatted_shift_entitlement).returns("some shifts")

        assert_current_node :shift_worker_done

        assert_state_variable :hours_per_shift, "7.25"
        assert_state_variable :shifts_per_shift_pattern, 4
        assert_state_variable :days_per_shift_pattern, 8

        assert_state_variable :holiday_entitlement_shifts, "some shifts"
      end
    end # full year

    context "starting this year" do
      setup do
        add_response "starting"
      end

      should "ask your start date" do
        assert_current_node :what_is_your_starting_date?
      end

      context "with a date" do
        setup do
          add_response "#{Date.today.year}-02-16"
        end

        should "ask when your leave year starts" do
          assert_current_node :when_does_your_leave_year_start?
        end

        context "with a leave year start date" do
          setup do
            add_response "#{Date.today.year}-07-01"
          end

          should "ask how many hours in each shift" do
            assert_current_node :shift_worker_hours_per_shift?
          end

          should "ask how many shifts per shift pattern" do
            add_response "8"
            assert_current_node :shift_worker_shifts_per_shift_pattern?
          end

          should "ask how many days per shift pattern" do
            add_response "8"
            add_response "4"
            assert_current_node :shift_worker_days_per_shift_pattern?
          end

          should "be done when all entered" do
            add_response "7.5"
            add_response "4"
            add_response "8"

            SmartAnswer::Calculators::HolidayEntitlement
              .expects(:new)
              .with(
                start_date: Date.parse("#{Date.today.year}-02-16"),
                leaving_date: nil,
                leave_year_start_date: Date.parse("#{Date.today.year}-07-01"),
                hours_per_shift: 7.5,
                shifts_per_shift_pattern: 4,
                days_per_shift_pattern: 8,
              ).returns(@stubbed_calculator)
            @stubbed_calculator.expects(:formatted_shift_entitlement).returns("some shifts")

            assert_current_node :shift_worker_done

            assert_state_variable :hours_per_shift, "7.5"
            assert_state_variable :shifts_per_shift_pattern, 4
            assert_state_variable :days_per_shift_pattern, 8

            assert_state_variable :holiday_entitlement_shifts, "some shifts"
          end
        end # with a leave year start date
      end # with a date
    end # starting this year

    context "leaving this year" do
      setup do
        add_response "leaving"
      end

      should "ask your leaving date" do
        assert_current_node :what_is_your_leaving_date?
      end

      context "with a date" do
        setup do
          add_response "#{Date.today.year}-02-16"
        end

        should "ask when your leave year starts" do
          assert_current_node :when_does_your_leave_year_start?
        end

        context "with a leave year start date" do
          setup do
            add_response "#{Date.today.year}-08-01"
          end

          should "ask how many hours in each shift" do
            assert_current_node :shift_worker_hours_per_shift?
          end

          should "ask how many shifts per shift pattern" do
            add_response "8"
            assert_current_node :shift_worker_shifts_per_shift_pattern?
          end

          should "ask how many days per shift pattern" do
            add_response "8"
            add_response "4"
            assert_current_node :shift_worker_days_per_shift_pattern?
          end

          should "be done when all entered" do
            add_response "7"
            add_response "4"
            add_response "8"

            SmartAnswer::Calculators::HolidayEntitlement
              .expects(:new)
              .with(
                start_date: nil,
                leaving_date: Date.parse("#{Date.today.year}-02-16"),
                leave_year_start_date: Date.parse("#{Date.today.year}-08-01"),
                hours_per_shift: 7,
                shifts_per_shift_pattern: 4,
                days_per_shift_pattern: 8,
              ).returns(@stubbed_calculator)
            @stubbed_calculator.expects(:formatted_shift_entitlement).returns("some shifts")

            assert_current_node :shift_worker_done

            assert_state_variable :hours_per_shift, "7"
            assert_state_variable :shifts_per_shift_pattern, 4
            assert_state_variable :days_per_shift_pattern, 8

            assert_state_variable :holiday_entitlement_shifts, "some shifts"
          end
        end # with a leave year start date
      end # with a date
    end # leaving this year

    context "starting and leaving this year" do
      setup do
        add_response "starting-and-leaving"
      end

      should "ask your start date" do
        assert_current_node :what_is_your_starting_date?
      end

      context "with a date" do
        setup do
          add_response "#{Date.today.year}-02-16"
        end

        should "ask your leave date" do
          assert_current_node :what_is_your_leaving_date?
        end

        context "with a leaving date" do
          setup do
            add_response "#{Date.today.year}-08-01"
          end

          should "ask how many hours in each shift" do
            assert_current_node :shift_worker_hours_per_shift?
          end

          should "ask how many shifts per shift pattern" do
            add_response "8"
            assert_current_node :shift_worker_shifts_per_shift_pattern?
          end

          should "ask how many days per shift pattern" do
            add_response "8"
            add_response "4"
            assert_current_node :shift_worker_days_per_shift_pattern?
          end

          should "be done when all entered" do
            add_response "7"
            add_response "4"
            add_response "8"

            SmartAnswer::Calculators::HolidayEntitlement
              .expects(:new)
              .with(
                start_date: Date.parse("#{Date.today.year}-02-16"),
                leaving_date: Date.parse("#{Date.today.year}-08-01"),
                leave_year_start_date: nil,
                hours_per_shift: 7,
                shifts_per_shift_pattern: 4,
                days_per_shift_pattern: 8,
              ).returns(@stubbed_calculator)
            @stubbed_calculator.expects(:formatted_shift_entitlement).returns("some shifts")

            assert_current_node :shift_worker_done

            assert_state_variable :hours_per_shift, "7"
            assert_state_variable :shifts_per_shift_pattern, 4
            assert_state_variable :days_per_shift_pattern, 8

            assert_state_variable :holiday_entitlement_shifts, "some shifts"
          end
        end # with a leave year start date
      end # with a date
    end # leaving this year
  end # shift worker
end
