require_relative '../../test_helper'
require_relative 'flow_test_helper'

require "smart_answer_flows/calculate-your-redundancy-pay"

class CalculateYourRedundancyPayTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    Timecop.freeze("2018-08-31")
    stub_shared_component_locales
    setup_for_testing_flow SmartAnswer::CalculateYourRedundancyPayFlow
  end

  should "ask when you were made redundant" do
    assert_current_node :date_of_redundancy?
  end

  context "answer with a valid date (within 4 years of now)" do
    setup do
      # Freeze to 2017 so that 2013 is still an allowed date
      Timecop.freeze("2017-08-31")
      add_response '2013-01-31'
    end

    should "be in employee flow for age" do
      assert_current_node :age_of_employee?
    end

    context "42 years old" do
      setup do
        add_response "42"
      end

      should "ask how long the employee has been employed" do
        assert_current_node :years_employed?
      end

      context "under 2 years" do
        setup do
          add_response "1.8"
        end

        should "bypass the salary question" do
          assert_current_node :done_no_statutory
        end
      end

      context "over 2 years" do
        setup do
          add_response "4.5"
        end

        should "ask for salary" do
          assert_current_node :weekly_pay_before_tax?
        end

        context "with a weekly salary of more than the rate before tax" do
          setup do
            # 2012-2013 rate is 430
            add_response "1500"
          end

          should "give me statutory redundancy" do
            assert_current_node :done
          end

          should "give me a figure no higher than the rate per week" do
            # 2012-2013 rate is 430
            assert_state_variable :statutory_redundancy_pay, "1,935"
            assert_state_variable :statutory_redundancy_pay_ni, "1,935"
          end

          should "give me 4.5 weeks total entitlement" do
            assert_state_variable :number_of_weeks_entitlement, 4.5
          end
        end
      end
    end

    context "between 22 and 41" do
      setup do
        add_response "22-40"
      end

      should "ask how long the employee has been employed" do
        assert_current_node :years_employed?
      end

      context "under 2 years" do
        setup do
          add_response "1"
        end

        should "bypass the salary question" do
          assert_current_node :done_no_statutory
        end
      end

      context "over 2 years" do
        setup do
          add_response "4"
        end

        should "ask for salary" do
          assert_current_node :weekly_pay_before_tax?
        end

        context "weekly salary of over the rate before tax" do
          setup do
            # 2012-2013 rate is 430
            add_response "1500"
          end

          should "give me statutory redundancy" do
            assert_current_node :done
          end

          should "give me a figure no higher than the rate per week" do
            # 2012-2013 rate is 430
            assert_state_variable :statutory_redundancy_pay, "860"
            assert_state_variable :statutory_redundancy_pay_ni, "860"
          end

          should "give me 2 weeks total entitlement" do
            assert_state_variable :number_of_weeks_entitlement, 2.0
          end
        end

        context "weekly salary of under the rate before tax" do
          setup do
            # 2012-2013 rate is 430
            add_response "300"
          end

          should "give me a figure below the rate" do
            # 2012-2013 rate is 430
            assert_state_variable :statutory_redundancy_pay, "600"
            assert_state_variable :statutory_redundancy_pay_ni, "600"
          end

          should "give me 2 weeks total entitlement" do
            assert_state_variable :number_of_weeks_entitlement, 2.0
          end
        end
      end
    end

    context "catches years_employed greater than age_of_employee" do
      context "be 18 years old and worked 20" do
        setup do
          add_response 18
        end
        should "fail on 4 years" do
          add_response 4
          assert_current_node_is_error
        end
        should "fail on 20 years" do
          add_response 20
          assert_current_node_is_error
        end
        should "succeed on 3" do
          add_response 3
          assert_current_node :weekly_pay_before_tax?
        end
        should "succeed on 2" do
          add_response 2
          assert_current_node :weekly_pay_before_tax?
        end
      end
    end

    context "21 years of age" do
      setup do
        add_response "21"
      end

      should "ask how long the employee has been employed" do
        assert_current_node :years_employed?
      end

      context "under 2 years" do
        setup do
          add_response "1"
        end

        should "bypass the salary question" do
          assert_current_node :done_no_statutory
        end
      end

      context "over 2 years" do
        setup do
          add_response "6"
        end

        should "ask for salary" do
          assert_current_node :weekly_pay_before_tax?
        end

        context "weekly salary of over the rate before tax" do
          setup do
            # 2012-2013 rate is 430
            add_response "1500"
          end

          should "give me statutory redundancy" do
            assert_current_node :done
          end

          should "give me a figure no higher than the rate per week" do
            # 2012-2013 rate is 430
            assert_state_variable :statutory_redundancy_pay, "1,290"
            assert_state_variable :statutory_redundancy_pay_ni, "1,290"
          end

          should "give me 3 weeks total entitlement" do
            assert_state_variable :number_of_weeks_entitlement, 3.0
          end
        end

        context "weekly salary of under the rate before tax" do
          setup do
            # 2012-2013 rate is 430
            add_response "300"
          end

          should "give me a figure below the rate" do
            # 2012-2013 rate is 430
            assert_state_variable :statutory_redundancy_pay, "900"
            assert_state_variable :statutory_redundancy_pay_ni, "900"
          end

          should "give me 3 weeks total entitlement" do
            assert_state_variable :number_of_weeks_entitlement, 3.0
          end
        end
      end
    end
  end

  context "2012/2013 (rate ends on 1st Feb)" do
    should "use the correct rates" do
      Timecop.freeze("2017-08-31")
      add_response '2013-01-31'
      add_response '42'
      add_response '4.5'
      add_response '700'
      assert_current_node :done
      assert_state_variable :rate, 430
      assert_state_variable :ni_rate, 430
    end
  end

  context "2013/2014 (rate starts on 1st Feb)" do
    should "use the correct rates" do
      Timecop.freeze("2017-08-31")
      add_response '2013-02-01'
      add_response '42'
      add_response '4.5'
      add_response '700'
      assert_current_node :done
      assert_state_variable :rate, 450
      assert_state_variable :ni_rate, 450
    end
  end

  context "2015/2016" do
    should "Use the correct rates" do
      add_response '2015-05-01'
      add_response '22'
      add_response '7'
      add_response '700'
      assert_current_node :done
      assert_state_variable :rate, 475
      assert_state_variable :ni_rate, 490
      assert_state_variable :max_amount, "14,250"
      assert_state_variable :ni_max_amount, "14,700"
      assert_state_variable :statutory_redundancy_pay, "1,662.50"
      assert_state_variable :statutory_redundancy_pay_ni, "1,715"
    end
  end

  context "2017/2018" do
    should "Use the correct rates" do
      add_response '2017-05-01'
      add_response '22'
      add_response '7'
      add_response '700'
      assert_current_node :done
      assert_state_variable :rate, 489
      assert_state_variable :ni_rate, 500
      assert_state_variable :max_amount, "14,670"
      assert_state_variable :ni_max_amount, "15,000"
      assert_state_variable :statutory_redundancy_pay, "1,711.50"
      assert_state_variable :statutory_redundancy_pay_ni, "1,750"
    end
  end

  context "2018/2019" do
    should "Use the correct rates" do
      add_response '2018-05-01'
      add_response '22'
      add_response '7'
      add_response '700'
      assert_current_node :done
      assert_state_variable :rate, 508
      assert_state_variable :ni_rate, 500
      assert_state_variable :max_amount, "15,240"
      assert_state_variable :ni_max_amount, "15,000"
      assert_state_variable :statutory_redundancy_pay, "1,778"
      assert_state_variable :statutory_redundancy_pay_ni, "1,750"
    end
  end
end
