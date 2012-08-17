require_relative "../../test_helper"
require_relative "flow_test_helper"

class BecomeAMotorcycleInstructorTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow "become-a-motorcycle-instructor"
  end

  should "ask if you are already qualified" do
    assert_current_node :qualified_motorcycle_instructor?
  end

  context "is a down-trained CBT instructor" do
    should "show application options" do
      add_response :down_trained_cbt_instructor
      assert_current_node :down_trained_cbt_instructor_response
    end
  end

  context "is a cardington-assessed CBT instructor" do
    should "show application options" do
      add_response :cardington_cbt_instructor
      assert_current_node :cardington_cbt_instructor_response
    end
  end

  context "direct access scheme instructor" do
    should "show application options" do
      add_response :direct_access_instructor
      assert_current_node :direct_access_instructor_response
    end
  end

  context "no qualifications" do
    setup do
      add_response :no
    end

    should "ask if over 21" do
      assert_current_node :over_21?
    end

    context "under 21" do
      should "say you are under age" do
        add_response :no
        assert_current_node :too_young
      end
    end

    context "over 21" do
      setup do
        add_response :yes
      end

      should "ask if you have a driving licence" do
        assert_current_node :driving_licence?
      end

      context "no driving licence" do
        should "say you need a licence" do
          add_response :no
          assert_current_node :need_licence
        end
      end

      context "has a driving licence" do
        setup do
          add_response :yes
        end

        should "ask if you have a motorcycle licence" do
          assert_current_node :motorcycle_licence?
        end

        context "have a motorcycle licence" do
          should "show application instructions" do
            add_response :yes
            assert_current_node :application_instructions
          end
        end

        context "had licence for less than 3 years" do
          should "say you need to be licenced for longer" do
            add_response :no
            assert_current_node :need_longer_licence
          end
        end
      end
    end
  end
end