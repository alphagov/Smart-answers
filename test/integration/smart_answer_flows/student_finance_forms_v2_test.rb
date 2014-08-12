# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class StudentFinanceFormsV2Test < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'student-finance-forms-v2'
  end

  should "ask what type of student you are" do
    assert_current_node :type_of_student?
  end

  context "UK student full time" do
    setup do
      add_response 'uk-full-time'
    end

    should "ask what you need the form for" do
      assert_current_node :form_needed_for_1?
    end

    context "apply for student loans and grants" do
      setup do
        add_response 'apply-loans-grants'
      end

      should "ask what year you want funding for" do
        assert_current_node :what_year?
      end

      context "2013 to 2014" do
        setup do
          add_response 'year-1314'
        end

        should "ask are you a continuing student" do
          assert_current_node :continuing_student?
        end

        should "continuing student = yes" do
          add_response 'continuing-student'
          assert_current_node :outcome_uk_ft_1314_continuing
          assert_phrase_list :form_destination, [:postal_address_uk]
        end

        should "continuing student = no" do
          add_response 'new-student'
          assert_current_node :outcome_uk_ft_1314_new
          assert_phrase_list :form_destination, [:postal_address_uk]
        end
      end

      context "2014 to 2015" do
        setup do
          add_response 'year-1415'
        end

        should "ask are you a continuing student" do
          assert_current_node :continuing_student?
        end

        should "continuing student = yes" do
          add_response 'continuing-student'
          assert_current_node :outcome_uk_ft_1415_continuing
          assert_phrase_list :form_destination, [:postal_address_uk]
        end

        should "continuing student = no" do
          add_response 'new-student'
          assert_current_node :outcome_uk_ft_1415_new
          assert_phrase_list :form_destination, [:postal_address_uk]
        end
      end
    end

    context "send proof of identity" do
      setup do
        add_response 'proof-identity'
      end

      should "ask what year you want funding for" do
        assert_current_node :what_year?
      end

      should "year = 2013/14" do
        add_response 'year-1314'
        assert_current_node :outcome_proof_identity_1314
        assert_phrase_list :form_destination, [:postal_address_uk]
      end

      should "year = 2014/15" do
        add_response 'year-1415'
        assert_current_node :outcome_proof_identity_1415
        assert_phrase_list :form_destination, [:postal_address_uk]
      end
    end

    context "send parents or partners details" do
      setup do
        add_response 'income-details'
      end

      should "ask what year you want funding for" do
        assert_current_node :what_year?
      end

      should "year = 2013/14" do
        add_response 'year-1314'
        assert_current_node :outcome_parent_partner_1314
        assert_phrase_list :form_destination, [:postal_address_uk]
      end

      should "year = 2014/15" do
        add_response 'year-1415'
        assert_current_node :outcome_parent_partner_1415
        assert_phrase_list :form_destination, [:postal_address_uk]
      end
    end

    context "apply DSA" do
      setup do
        add_response 'apply-dsa'
      end

      should "ask what year you want funding for" do
        assert_current_node :what_year?
      end

      should "year = 2013/14" do
        add_response 'year-1314'
        assert_current_node :outcome_dsa_1314
        assert_phrase_list :form_destination, [:postal_address_uk]
      end

      should "year = 2014/15" do
        add_response 'year-1415'
        assert_current_node :outcome_dsa_1415
        assert_phrase_list :form_destination, [:postal_address_uk]
      end
    end

    context "claim DSA expenses" do
      setup do
        add_response 'dsa-expenses'
        assert_current_node :outcome_dsa_expenses
        assert_phrase_list :form_destination, [:postal_address_uk]
      end
    end

    context "claim CcG" do
      setup do
        add_response 'apply-ccg'
      end

      should "ask what year you want funding for" do
        assert_current_node :what_year?
      end

      should "year = 2013/14" do
        add_response 'year-1314'
        assert_current_node :outcome_ccg_1314
        assert_phrase_list :form_destination, [:postal_address_uk]
      end

      should "year = 2014/15" do
        add_response 'year-1415'
        assert_current_node :outcome_ccg_1415
        assert_phrase_list :form_destination, [:postal_address_uk]
      end
    end

    context "claim CcG expenses" do
      setup do
        add_response 'ccg-expenses'
        assert_current_node :outcome_ccg_expenses
        assert_phrase_list :form_destination, [:postal_address_uk]
      end
    end

    context "claim travel grants" do
      setup do
        add_response 'travel-grant'
        assert_current_node :outcome_travel
      end
    end
  end

  context "UK student part time" do
    setup do
      add_response 'uk-part-time'
    end

    should "ask what you need the form for" do
      assert_current_node :form_needed_for_2?
    end

    context "apply for student loans and grants" do
      setup do
        add_response 'apply-loans-grants'
      end

      should "ask what year you want funding for" do
        assert_current_node :what_year?
      end

        context "2013 to 2014" do
          setup do
            add_response 'year-1314'
          end

          should "ask are you a continuing student" do
            assert_current_node :continuing_student?
          end

          context "continuing student = yes" do
            setup do
              add_response 'continuing-student'
            end

            should "course start before 01/09/12" do
              add_response 'course-start-before-01092012'
              assert_current_node :outcome_uk_pt_1314_grant
              assert_phrase_list :form_destination, [:postal_address_uk]
            end

            should "course start after 01/09/12" do
              add_response 'course-start-after-01092012'
              assert_current_node :outcome_uk_pt_1314_continuing
              assert_phrase_list :form_destination, [:postal_address_uk]
            end
          end

          context "continuing student = no" do
            setup do
              add_response 'new-student'
            end

            should "course start before 01/09/12" do
              add_response 'course-start-before-01092012'
              assert_current_node :outcome_uk_pt_1314_grant
              assert_phrase_list :form_destination, [:postal_address_uk]
            end

            should "course start after 01/09/12" do
              add_response 'course-start-after-01092012'
              assert_current_node :outcome_uk_pt_1314_new
              assert_phrase_list :form_destination, [:postal_address_uk]
            end
          end
        end

        context "2014 to 2015" do
          setup do
            add_response 'year-1415'
          end

          should "ask are you a continuing student" do
            assert_current_node :continuing_student?
          end

          context "continuing student = yes" do
            setup do
              add_response 'continuing-student'
            end

            should "course start before 01/09/12" do
              add_response 'course-start-before-01092012'
              assert_current_node :outcome_uk_pt_1415_grant
              assert_phrase_list :form_destination, [:postal_address_uk]
            end

            should "course start after 01/09/12" do
              add_response 'course-start-after-01092012'
              assert_current_node :outcome_uk_pt_1415_continuing
              assert_phrase_list :form_destination, [:postal_address_uk]
            end
          end

          context "continuing student = no" do
          setup do
            add_response 'new-student'
          end

          should "course start before 01/09/12" do
            add_response 'course-start-before-01092012'
            assert_current_node :outcome_uk_pt_1415_grant
            assert_phrase_list :form_destination, [:postal_address_uk]
          end

          should "course start after 01/09/12" do
            add_response 'course-start-after-01092012'
            assert_current_node :outcome_uk_pt_1415_new
            assert_phrase_list :form_destination, [:postal_address_uk]
          end
        end
      end
    end

    context "send proof of identity" do
      setup do
        add_response 'proof-identity'
      end

      should "ask what year you want funding for" do
        assert_current_node :what_year?
      end

      should "year = 2013/14" do
        add_response 'year-1314'
        assert_current_node :outcome_proof_identity_1314_pt
        assert_phrase_list :form_destination, [:postal_address_uk]
      end

      should "year = 2012/13" do
        add_response 'year-1415'
        assert_current_node :outcome_proof_identity_1415
        assert_phrase_list :form_destination, [:postal_address_uk]
      end
    end

    context "apply DSA" do
      setup do
        add_response 'apply-dsa'
      end

      should "ask what year you want funding for" do
        assert_current_node :what_year?
      end
      should "year = 2013/14" do
        add_response 'year-1314'
        assert_current_node :outcome_dsa_1314_pt
      end

      should "year = 2014/15" do
        add_response 'year-1415'
        assert_current_node :outcome_dsa_1415
      end

      should "year = 2014/15" do
        add_response 'year-1415'
        assert_state_variable :student_type, 'uk-part-time'
        assert_current_node :outcome_dsa_1415_pt
      end
    end

    context "claim DSA expenses" do
      setup do
        add_response 'dsa-expenses'
        assert_current_node :outcome_dsa_expenses
        assert_phrase_list :form_destination, [:postal_address_uk]
      end
    end
  end

  context "EU student full time" do
    setup do
      add_response 'eu-full-time'
    end

    should "ask what year you want funding for" do
      assert_current_node :what_year?
    end

    context "2013 to 2014" do
      setup do
        add_response 'year-1314'
      end

      should "ask are you a continuing student" do
        assert_current_node :continuing_student?
      end

      should "continuing student = yes" do
        add_response 'continuing-student'
        assert_current_node :outcome_eu_ft_1314_continuing
        assert_phrase_list :form_destination, [:postal_address_eu]
      end

      should "continuing student = no" do
        add_response 'new-student'
        assert_current_node :outcome_eu_ft_1314_new
        assert_phrase_list :form_destination, [:postal_address_eu]
      end
    end

    context "2014 to 2015" do
      setup do
        add_response 'year-1415'
      end

      should "ask are you a continuing student" do
        assert_current_node :continuing_student?
      end

      should "continuing student = yes" do
        add_response 'continuing-student'
        assert_current_node :outcome_eu_ft_1415_continuing
        assert_phrase_list :form_destination, [:postal_address_eu]
      end

      should "continuing student = no" do
        add_response 'new-student'
        assert_current_node :outcome_eu_ft_1415_new
        assert_phrase_list :form_destination, [:postal_address_eu]
      end
    end
  end

  context "EU student part time" do
    setup do
      add_response 'eu-part-time'
    end

    should "ask what year you want funding for" do
      assert_current_node :what_year?
    end

    context "2013 to 2014" do
      setup do
        add_response 'year-1314'
      end

      should "ask are you a continuing student" do
        assert_current_node :continuing_student?
      end

      should "continuing student = yes" do
        add_response 'continuing-student'
        assert_current_node :outcome_eu_pt_1314_continuing
        assert_phrase_list :form_destination, [:postal_address_eu]
      end

      should "continuing student = no" do
        add_response 'new-student'
        assert_current_node :outcome_eu_pt_1314_new
        assert_phrase_list :form_destination, [:postal_address_eu]
      end
    end

    context "2014 to 2015" do
      setup do
        add_response 'year-1415'
      end

      should "ask are you a continuing student" do
        assert_current_node :continuing_student?
      end

      should "continuing student = yes" do
        add_response 'continuing-student'
        assert_current_node :outcome_eu_pt_1415_continuing
        assert_phrase_list :form_destination, [:postal_address_eu]
      end

      should "continuing student = no" do
        add_response 'new-student'
        assert_current_node :outcome_eu_pt_1415_new
        assert_phrase_list :form_destination, [:postal_address_eu]
      end
    end
  end

  # tests after the 24 March updates
  context "date is now after 24 March 2014 so should give the standard outcome" do
    setup do
      add_response 'eu-full-time'
      add_response 'year-1415'
    end
    should "ask whether you're a new or continuing student - year 1415 again" do
      assert_current_node :continuing_student?
    end
    should "take you to the outcome for new eu full-time students" do
      add_response 'new-student'
      assert_current_node :outcome_eu_ft_1415_new
    end
    should "take you to the outcome for continuing eu full-time students" do
      add_response 'continuing-student'
      assert_current_node :outcome_eu_ft_1415_continuing
    end
  end

end
