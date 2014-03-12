# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'
require 'gds_api/test_helpers/worldwide'


class OverseasPassportsTestV2 < ActiveSupport::TestCase
  include FlowTestHelper
  include GdsApi::TestHelpers::Worldwide

  setup do
    @location_slugs = %w(albania afghanistan australia austria azerbaijan bahamas bangladesh benin british-indian-ocean-territory burundi cameroon congo egypt greece haiti india indonesia iran iraq ireland italy jamaica jordan kazakhstan kenya kyrgyzstan malta morocco nepal nigeria north-korea pakistan pitcairn-island russia syria south-africa spain st-helena-ascension-and-tristan-da-cunha tanzania thailand the-occupied-palestinian-territories tunisia turkey ukraine united-kingdom uzbekistan yemen zimbabwe vietnam)
    worldwide_api_has_locations(@location_slugs)
    setup_for_testing_flow 'overseas-passports-v2'
  end

  ## Q1
  should "ask which country you are in" do
    assert_current_node :which_country_are_you_in?
  end

  # Afghanistan (An example of bespoke application process).
  context "answer Afghanistan" do
    setup do
      worldwide_api_has_organisations_for_location('afghanistan', read_fixture_file('worldwide/afghanistan_organisations.json'))
      add_response 'afghanistan'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
      assert_state_variable :current_location, 'afghanistan'
    end
    context "answer applying" do
      setup do
        add_response 'applying'
      end
      should "ask if the passport is for an adult or a child" do
        assert_current_node :child_or_adult_passport?
      end
      context "answer adult" do
        should "give the result and be done" do
          add_response 'adult'
          add_response 'afghanistan'
          assert_state_variable :application_type, 'ips_application_3'
          assert_current_node :ips_application_result
          assert_phrase_list :how_long_it_takes, [:how_long_applying_at_least_6_months, :how_long_it_takes_ips3]
          assert_phrase_list :cost, [:passport_courier_costs_ips3, :adult_passport_costs_ips3, :passport_costs_ips3]
          assert_phrase_list :send_your_application, [:send_application_ips3_afghanistan_apply_renew_old_replace, :send_application_embassy_address]
        end
      end
    end

    context "answer renewing" do
      setup do
        add_response 'renewing_new'
      end
      should "ask if the passport is for an adult or a child" do
        assert_current_node :child_or_adult_passport?
      end
      context "answer adult" do
        should "give the result and be done" do
          add_response 'adult'
          assert_state_variable :application_type, 'ips_application_3'
          assert_current_node :ips_application_result
          assert_phrase_list :cost, [:passport_courier_costs_ips3, :adult_passport_costs_ips3, :passport_costs_ips3]
          assert_phrase_list :send_your_application, [:send_application_ips3_afghanistan_renewing_new, :send_application_embassy_address]
        end
      end
    end
  end # Afghanistan

  # Iraq (An example of ips 1 application with some conditional phrases).
  context "answer Iraq" do
    setup do
      worldwide_api_has_organisations_for_location('iraq', read_fixture_file('worldwide/iraq_organisations.json'))
      add_response 'iraq'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
      assert_state_variable :current_location, 'iraq'
    end
    context "answer applying" do
      setup do
        add_response 'applying'
      end
      should "ask if the passport is for an adult or a child" do
        assert_current_node :child_or_adult_passport?
        assert_state_variable :application_type, 'ips_application_1'
      end
      context "answer adult" do
        setup do
          add_response 'adult'
        end
        should "ask the country of birth" do
          assert_current_node :country_of_birth?
        end
        context "answer UK" do
          setup do
            add_response 'united-kingdom'
          end
          should "give the result and be done" do
            assert_current_node :ips_application_result
            assert_phrase_list :fco_forms, [:adult_fco_forms]
            assert_phrase_list :how_long_it_takes, [:how_long_applying_ips1, :how_long_it_takes_ips1]
            assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
            assert_phrase_list :how_to_apply, [:how_to_apply_ips1, :hmpo_1_application_form, :ips_documents_group_3]
            assert_phrase_list :send_your_application, [:send_application_ips1_durham]
            assert_phrase_list :getting_your_passport, [:getting_your_passport_iraq]
            assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
            assert_match /Millburngate House/, outcome_body
          end
        end
      end
    end
  end # Iraq

  context "answer Benin, renewing old passport" do
    setup do
      worldwide_api_has_organisations_for_location('nigeria', read_fixture_file('worldwide/nigeria_organisations.json'))
      add_response 'benin'
      add_response 'renewing_old'
      add_response 'adult'
      add_response 'united-kingdom'
    end
    should "give the result with alternative embassy details" do
      assert_current_node :ips_application_result
      assert_phrase_list :fco_forms, [:adult_fco_forms]
      assert_phrase_list :how_long_it_takes, [:how_long_renewing_old_ips1, :how_long_it_takes_ips1]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_ips1, :hmpo_1_application_form, :ips_documents_group_3]
      assert_phrase_list :send_your_application, [:send_application_ips1_durham]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_benin, :getting_your_passport_contact_and_id]
      assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
    end
  end

  # Austria (An example of IPS application 1).
  context "answer Austria" do
    setup do
      worldwide_api_has_organisations_for_location('austria', read_fixture_file('worldwide/austria_organisations.json'))
      add_response 'austria'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
      assert_state_variable :current_location, 'austria'
    end
    context "answer applying" do
      setup do
        add_response 'applying'
      end
      should "ask if the passport is for an adult or a child" do
        assert_state_variable :application_type, 'ips_application_1'
        assert_state_variable :ips_number, "1"
        assert_current_node :child_or_adult_passport?
      end
      context "answer adult" do
        setup do
          add_response 'adult'
        end
        should "give the result and be done" do
          assert_phrase_list :fco_forms, [:adult_fco_forms]
          assert_current_node :country_of_birth?
        end
        context "answer Greece" do
          setup do
            add_response 'greece'
          end

          should "use the greek document group in the results" do
            assert_state_variable :supporting_documents, 'ips_documents_group_2'
          end

          should "give the result" do
            assert_current_node :ips_application_result_online
            assert_phrase_list :fco_forms, [:adult_fco_forms]
            assert_phrase_list :how_long_it_takes, [:how_long_applying_online, :how_long_additional_time_online]
            assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_applying, :how_to_apply_online_guidance_doc_group_2]
            assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1]
            assert_phrase_list :getting_your_passport, [:getting_your_passport_ips1]
            assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
          end
        end
      end
    end # Applying

    context "answer renewing old blue or black passport" do
      setup do
        add_response 'renewing_old'
        add_response 'adult'
      end
      should "ask which country you were born in" do
        assert_current_node :country_of_birth?
      end
    end # Renewing old style passport
    context "answer replacing" do
      setup do
        add_response 'replacing'
      end
      should "ask if the passport is for an adult or a child" do
        assert_current_node :child_or_adult_passport?
      end
      context "answer adult" do
        should "give the result and be done" do
          add_response 'adult'
          assert_state_variable :supporting_documents, 'ips_documents_group_1'
          assert_current_node :ips_application_result_online
          assert_phrase_list :fco_forms, [:adult_fco_forms]
          assert_phrase_list :how_long_it_takes, [:how_long_replacing_online, :how_long_additional_time_online]
          assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_replacing, :how_to_apply_online_guidance_doc_group_1]
          assert_phrase_list :cost, [:passport_courier_costs_replacing_ips1, :adult_passport_costs_replacing_ips1]
          assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
          assert_state_variable :embassy_address, nil
        end
      end
    end # Replacing
  end # Austria - IPS_application_1

  context "answer Spain, an example of online application, doc group 1" do
    setup do
      worldwide_api_has_organisations_for_location('spain', read_fixture_file('worldwide/spain_organisations.json'))
      add_response 'spain'
    end
    should "show how to apply online" do
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result_online
      assert_phrase_list :how_long_it_takes, [:how_long_applying_online, :how_long_additional_time_online]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_applying, :how_to_apply_online_guidance_doc_group_1]
      assert_match /the passport numbers of both parents/, outcome_body
    end
    should "show how to replace your passport online" do
      add_response 'replacing'
      add_response 'child'
      assert_current_node :ips_application_result_online
      assert_phrase_list :how_long_it_takes, [:how_long_replacing_online, :how_long_additional_time_online]
      assert_phrase_list :cost, [:passport_courier_costs_replacing_ips1, :child_passport_costs_replacing_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_replacing, :how_to_apply_online_guidance_doc_group_1]
    end
  end

  context "answer Greece, an example of online application, doc group 2" do
    setup do
      worldwide_api_has_organisations_for_location('greece', read_fixture_file('worldwide/greece_organisations.json'))
      add_response 'greece'
    end
    should "show how to apply online" do
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :ips_application_result_online
      assert_phrase_list :how_long_it_takes, [:how_long_renewing_new_online, :how_long_additional_time_online]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_renewing, :how_to_apply_online_guidance_doc_group_2]
      assert_match /Your application will take at least 4 weeks/, outcome_body
    end
    should "show how to replace your passport online" do
      add_response 'replacing'
      add_response 'child'
      assert_current_node :ips_application_result_online
      assert_phrase_list :how_long_it_takes, [:how_long_replacing_online, :how_long_additional_time_online]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :child_passport_costs_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_replacing, :how_to_apply_online_guidance_doc_group_2]
    end
  end

  context "answer Vietnam, an example of online application, doc group 3" do
    setup do
      worldwide_api_has_organisations_for_location('vietnam', read_fixture_file('worldwide/vietnam_organisations.json'))
      add_response 'vietnam'
    end
    should "show how to apply online" do
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :ips_application_result_online
      assert_phrase_list :how_long_it_takes, [:how_long_renewing_new_online, :how_long_additional_time_online]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_renewing, :how_to_apply_online_guidance_doc_group_3]
    end
    should "use the document group of the country of birth - Spain (which is 1)" do
      add_response 'applying'
      add_response 'adult'
      add_response 'spain'
      assert_current_node :ips_application_result_online
      assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_applying, :how_to_apply_online_guidance_doc_group_1]
    end
  end

  # Albania (an example of IPS application 2).
  context "answer Albania" do
    setup do
      worldwide_api_has_organisations_for_location('albania', read_fixture_file('worldwide/albania_organisations.json'))
      add_response 'albania'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
      assert_state_variable :current_location, 'albania'
    end
    context "answer applying" do
      setup do
        add_response 'applying'
      end
      should "ask if the passport is for an adult or a child" do
        assert_current_node :child_or_adult_passport?
        assert_state_variable :application_type, 'ips_application_1'
        assert_state_variable :ips_number, "1"
      end
      context "answer adult" do
        setup do
          add_response 'adult'
        end
        should "ask which country you were born in" do
          assert_current_node :country_of_birth?
        end
        context "answer Spain" do
          should "give the application result" do
            add_response "spain"
            assert_current_node :ips_application_result_online
            assert_phrase_list :how_long_it_takes, [:how_long_applying_online, :how_long_additional_time_online]
            assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_applying, :how_to_apply_online_guidance_doc_group_1]
            assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1]
            assert_phrase_list :getting_your_passport, [:getting_your_passport_ips1]
            assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
            assert_state_variable :embassy_address, nil
            assert_state_variable :supporting_documents, 'ips_documents_group_1'
          end
        end
        context "answer UK" do
          should "give the application result with the UK documents" do
            add_response "united-kingdom"
            assert_current_node :ips_application_result_online
            assert_phrase_list :how_long_it_takes, [:how_long_applying_online, :how_long_additional_time_online]
            assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_applying, :how_to_apply_online_guidance_doc_group_3]
            assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1]
            assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
            assert_state_variable :embassy_address, nil
            assert_state_variable :supporting_documents, 'ips_documents_group_3'
          end
        end
      end
    end # Applying
  end # Albania - IPS_application_2
  
  # Morocco (an example of IPS application 2 with custom phrases).
  context "answer Morocco" do
    setup do
      worldwide_api_has_organisations_for_location('morocco', read_fixture_file('worldwide/morocco_organisations.json'))
      add_response 'morocco'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
      assert_state_variable :current_location, 'morocco'
    end
    context "answer replacing" do
      setup do
        add_response 'replacing'
      end
      should "ask if the passport is for an adult or a child" do
        assert_current_node :child_or_adult_passport?
        assert_state_variable :application_type, 'ips_application_2'
        assert_state_variable :ips_number, "2"
      end
      should "return morocco specific phrases given an adult" do
        add_response 'adult'
        assert_state_variable :supporting_documents, 'ips_documents_group_3'
        assert_current_node :ips_application_result
        assert_phrase_list :fco_forms, [:adult_fco_forms]
        assert_phrase_list :how_long_it_takes, [:how_long_6_weeks, :how_long_it_takes_ips2]
        assert_phrase_list :how_to_apply, [:how_to_apply_ips2, :hmpo_1_application_form, :ips_documents_group_3]
        assert_phrase_list :cost, [:passport_courier_costs_ips2, :adult_passport_costs_ips2, :passport_costs_ips_cash]
        assert_phrase_list :send_your_application, [:send_application_ips2, :send_application_embassy_address]
        assert_phrase_list :getting_your_passport, [:getting_your_passport_ips2]
        assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
        assert_match /28 Avenue S.A.R. Sidi Mohammed/, outcome_body
      end
    end # Applying
  end # Morocco - IPS_application_2

  # Ajerbaijan (an example of IPS application 3).
  context "answer Azerbaijan" do
    setup do
      worldwide_api_has_organisations_for_location('azerbaijan', read_fixture_file('worldwide/azerbaijan_organisations.json'))
      add_response 'azerbaijan'
    end
    should "ask if you are renewing, replacing or applying for a passport" do
      assert_current_node :renewing_replacing_applying?
      assert_state_variable :current_location, 'azerbaijan'
    end
    context "answer replacing adult passport" do
      setup do
        add_response 'replacing'
        add_response 'adult'
        assert_state_variable :application_type, 'ips_application_3'
        assert_state_variable :ips_number, "3"
      end
      should "give the IPS application result" do
        assert_current_node :ips_application_result
        assert_phrase_list :how_long_it_takes, [:how_long_replacing_ips3, :how_long_it_takes_ips3]
        assert_phrase_list :how_to_apply, [:how_to_apply_ips3, :hmpo_1_application_form, :ips_documents_group_3]
        assert_phrase_list :cost, [:passport_courier_costs_ips3, :adult_passport_costs_ips3, :passport_costs_ips3]
        assert_phrase_list :send_your_application, [:send_application_ips3, :send_application_embassy_address]
        assert_phrase_list :getting_your_passport, [:getting_your_passport_ips3]
        assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
        assert_match /45 Khagani Street/, outcome_body
      end
    end # Applying
  end # Azerbaijan - IPS_application_3

  # Burundi (An example of IPS 3 application with some conditional phrases).
  context "answer Burundi" do
    setup do
      worldwide_api_has_organisations_for_location('burundi', read_fixture_file('worldwide/burundi_organisations.json'))
      add_response 'burundi'
    end

    should "give the correct result when renewing new style passport" do
      add_response 'renewing_new'
      add_response 'adult'
      assert_phrase_list :send_your_application,
        [:send_application_ips3_burundi_renewing_new, :send_application_embassy_address]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_burundi_renewing_new]
    end

    should "give the correct result when renewing old style passport" do
      add_response 'renewing_old'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_phrase_list :send_your_application, [
        :send_application_ips3_burundi_apply_renew_old_replace,
        :send_application_embassy_address
      ]
      assert_phrase_list :getting_your_passport, [
        :getting_your_passport_burundi,
        :getting_your_passport_contact_and_id
      ]
    end

    should "give the correct result when applying for the first time" do
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_phrase_list :send_your_application, [
        :send_application_ips3_burundi_apply_renew_old_replace,
        :send_application_embassy_address
      ]
      assert_phrase_list :getting_your_passport, [
        :getting_your_passport_burundi,
        :getting_your_passport_contact_and_id
      ]
    end

    should "give the correct result when replacing lost or stolen passport" do
      add_response 'replacing'
      add_response 'adult'
      assert_phrase_list :send_your_application, [
        :send_application_ips3_burundi_apply_renew_old_replace,
        :send_application_embassy_address
      ]
      assert_phrase_list :getting_your_passport, [
        :getting_your_passport_burundi,
        :getting_your_passport_contact_and_id
      ]
    end
  end # Burundi

  # North Korea (An example of IPS 3 application with some conditional phrases).
  context "answer North Korea" do
    setup do
      worldwide_api_has_organisations_for_location('north-korea', read_fixture_file('worldwide/north-korea_organisations.json'))
      add_response 'north-korea'
    end

    should "give the correct result when renewing new style passport" do
      add_response 'renewing_new'
      add_response 'adult'
      assert_phrase_list :how_long_it_takes, [:how_long_6_weeks, :how_long_it_takes_ips3]
      assert_phrase_list :send_your_application, [:"send_application_ips3_north-korea_renewing_new"]
      assert_phrase_list :getting_your_passport, [:"getting_your_passport_north-korea", :getting_your_passport_contact, :getting_your_passport_id_renewing_new]
    end

    should "give the correct result when renewing old style passport" do
      add_response 'renewing_old'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_phrase_list :how_long_it_takes, [:how_long_8_weeks_with_interview, :how_long_it_takes_ips3]
      assert_phrase_list :getting_your_passport, [:"getting_your_passport_north-korea", :getting_your_passport_contact, :getting_your_passport_id_apply_renew_old_replace]
    end

    should "give the correct result when applying for the first time" do
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_phrase_list :how_long_it_takes, [:how_long_8_weeks_with_interview, :how_long_it_takes_ips3]
      assert_phrase_list :getting_your_passport, [:"getting_your_passport_north-korea", :getting_your_passport_contact, :getting_your_passport_id_apply_renew_old_replace]
    end

    should "give the correct result when replacing lost or stolen passport" do
      add_response 'replacing'
      add_response 'adult'
      assert_phrase_list :how_long_it_takes, [:how_long_8_weeks_replacing, :how_long_it_takes_ips3]
      assert_phrase_list :getting_your_passport, [:"getting_your_passport_north-korea", :getting_your_passport_contact, :getting_your_passport_id_apply_renew_old_replace]
    end

    should "give the correct method of payment guidance" do
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_phrase_list :cost, [:passport_courier_costs_ips3, :adult_passport_costs_ips3, :passport_costs_ips_euros]
    end
  end # North Korea

  context "answer Ireland, replacement, adult passport" do
    should "give the ips online application result" do
      worldwide_api_has_organisations_for_location('ireland', read_fixture_file('worldwide/ireland_organisations.json'))
      add_response 'ireland'
      add_response 'replacing'
      add_response 'adult'
      assert_phrase_list :how_long_it_takes, [:how_long_replacing_online, :how_long_additional_time_online]
      assert_phrase_list :cost, [:passport_courier_costs_replacing_ips1, :adult_passport_costs_replacing_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_replacing, :how_to_apply_online_guidance_doc_group_1]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_ips1]
      assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
    end
  end # Ireland (FCO with custom phrases)

  context "answer India" do
    setup do
      worldwide_api_has_organisations_for_location('india', read_fixture_file('worldwide/india_organisations.json'))
      add_response 'india'
    end
    context "applying, adult passport" do
      should "give the ips result" do
        add_response 'applying'
        add_response 'adult'
        add_response 'india'
        assert_current_node :ips_application_result
        assert_phrase_list :how_long_it_takes, [:how_long_applying_16_weeks, :how_long_it_takes_ips3]
        assert_phrase_list :send_your_application, [:send_application_ips3_india, :send_application_ips3_must_post, :send_application_embassy_address]
        assert_phrase_list :cost, [:passport_courier_costs_india, :adult_passport_costs_ips3, :passport_costs_ips3]
        assert_phrase_list :getting_your_passport, [:getting_your_passport_india]
      end
    end
    context "renewing a new adult passport" do
      should "give the ips result" do
        add_response 'renewing_new'
        add_response 'adult'
        assert_current_node :ips_application_result
        assert_phrase_list :how_long_it_takes, [:how_long_5_weeks, :how_long_it_takes_ips3]
      end
    end
    context "renewing a new adult passport" do
      should "give the ips result" do
        add_response 'replacing'
        add_response 'adult'
        assert_current_node :ips_application_result
        assert_phrase_list :how_long_it_takes, [:how_long_5_weeks, :how_long_it_takes_ips3]
      end
    end
  end # India

  context "answer Tanzania, replacement, adult passport" do
    should "give the ips online result with custom phrases" do
      worldwide_api_has_organisations_for_location('tanzania', read_fixture_file('worldwide/tanzania_organisations.json'))
      add_response 'tanzania'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result_online
      assert_phrase_list :how_long_it_takes, [:how_long_applying_djibouti_tanzania, :how_long_additional_time_online]
    end
  end # Tanzania

  context "answer Congo, replacement, adult passport" do
    should "give the result with custom phrases" do
      worldwide_api_has_organisations_for_location('congo', read_fixture_file('worldwide/congo_organisations.json'))
      add_response 'congo'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_phrase_list :fco_forms, [:adult_fco_forms]
      assert_phrase_list :how_long_it_takes, [:how_long_applying_ips1, :how_long_it_takes_ips1]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_ips1, :hmpo_1_application_form, :ips_documents_group_3]
      assert_phrase_list :send_your_application, [:send_application_ips1_durham]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_congo, :getting_your_passport_contact_and_id]
      assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
    end
  end # Congo

  context "answer Indonesia, renewing_new, adult passport" do
    should "give the IPS result with custom phrases" do
      worldwide_api_has_organisations_for_location('indonesia', read_fixture_file('worldwide/indonesia_organisations.json'))
      add_response 'indonesia'
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :ips_application_result
      assert_phrase_list :fco_forms, [:adult_fco_forms]
      assert_phrase_list :how_long_it_takes, [:how_long_renewing_new_ips1, :how_long_it_takes_ips1]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_ips1, :send_colour_photocopy_bulletpoint, :hmpo_1_application_form, :ips_documents_group_2]
      assert_phrase_list :send_your_application, [:send_application_ips1]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_ips1]
      assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
    end
  end # Indonesia

  context "answer Malta, replacement, adult passport" do
    should "give the fco result with custom phrases" do
      worldwide_api_has_organisations_for_location('malta', read_fixture_file('worldwide/malta_organisations.json'))
      add_response 'malta'
      add_response 'replacing'
      add_response 'adult'
      assert_current_node :ips_application_result_online
      assert_phrase_list :cost, [:passport_courier_costs_replacing_ips1, :adult_passport_costs_replacing_ips1]
    end
  end # Malta (IPS1 with custom phrases)

  context "answer Italy, replacement, adult passport" do
    should "give the IPS online result" do
      worldwide_api_has_organisations_for_location('italy', read_fixture_file('worldwide/italy_organisations.json'))
      add_response 'italy'
      add_response 'replacing'
      add_response 'adult'
      assert_current_node :ips_application_result_online
      assert_phrase_list :how_long_it_takes, [:how_long_replacing_online, :how_long_additional_time_online]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_replacing, :how_to_apply_online_guidance_doc_group_2]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_ips1]
      assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
    end
  end # Italy (IPS online result)

  context "answer Jordan, replacement, adult passport" do
    should "give the ips1 result with custom phrases" do
      worldwide_api_has_organisations_for_location('jordan', read_fixture_file('worldwide/jordan_organisations.json'))
      add_response 'jordan'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_phrase_list :getting_your_passport, [:getting_your_passport_jordan]
      assert_current_node :ips_application_result
      assert_match /Millburngate House/, outcome_body
    end
  end # Jordan (IPS1 with custom phrases)

  context "answer Pitcairn Island, applying, adult passport" do
    should "give the IPS application result with custom phrases" do
      worldwide_api_has_organisations_for_location('pitcairn-island', read_fixture_file('worldwide/pitcairn-island_organisations.json'))
      add_response 'pitcairn-island'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_phrase_list :getting_your_passport, [:"getting_your_passport_pitcairn-island"]
      assert_phrase_list :send_your_application, [:"send_application_address_pitcairn-island"]
      assert_phrase_list :cost, [:"passport_courier_costs_pitcairn-island", :adult_passport_costs_ips1,
 :passport_costs_ips1]
    end
  end # Pitcairn Island (IPS1 with custom phrases)

  context "answer Ukraine, applying, adult passport" do
    should "give the IPS application result with custom phrases" do
      worldwide_api_has_organisations_for_location('ukraine', read_fixture_file('worldwide/ukraine_organisations.json'))
      add_response 'ukraine'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_phrase_list :cost, [:passport_courier_costs_ukraine, :adult_passport_costs_ips3, :passport_costs_ips3]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_ukraine]
      assert_phrase_list :send_your_application, [:send_application_ips3_ukraine_apply_renew_old_replace, :send_application_address_ukraine]
    end
  end # Ukraine (IPS3 with custom phrases)
  
  context "answer Ukraine, applying, adult passport" do
    should "give the IPS application result with custom phrases" do
      worldwide_api_has_organisations_for_location('ukraine', read_fixture_file('worldwide/ukraine_organisations.json'))
      add_response 'ukraine'
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :ips_application_result
      assert_phrase_list :cost, [:passport_courier_costs_ukraine, :adult_passport_costs_ips3, :passport_costs_ips3]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_ukraine, :getting_your_passport_contact, :getting_your_passport_id_renewing_new]
      assert_phrase_list :send_your_application, [:send_application_ips3_ukraine_renewing_new, :send_application_address_ukraine]
    end
  end # Ukraine (IPS3 with custom phrases)
  
  context "answer nepal, renewing new, adult passport" do
    should "give the IPS application result with custom phrases" do
      worldwide_api_has_organisations_for_location('nepal', read_fixture_file('worldwide/nepal_organisations.json'))
      add_response 'nepal'
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :ips_application_result
      assert_phrase_list :send_your_application, [:send_application_ips3_nepal_renewing_new, :"send_application_address_nepal"]
      assert_phrase_list :cost, [:passport_courier_costs_nepal, :adult_passport_costs_ips3, :passport_costs_ips3]    
      assert_state_variable :send_colour_photocopy_bulletpoint, nil
    end
  end # nepal (IPS3 with custom phrases)
  
  context "answer nepal, lost or stolen, adult passport" do
    should "give the IPS application result with custom phrases" do
      worldwide_api_has_organisations_for_location('nepal', read_fixture_file('worldwide/pitcairn-island_organisations.json'))
      add_response 'nepal'
      add_response 'replacing'
      add_response 'adult'
      assert_current_node :ips_application_result
      assert_phrase_list :send_your_application, [:send_application_ips3_nepal_apply_renew_old_replace, :"send_application_address_nepal"]
      assert_phrase_list :cost, [:passport_courier_costs_nepal, :adult_passport_costs_ips3, :passport_costs_ips3]
      assert_state_variable :send_colour_photocopy_bulletpoint, nil
    end
  end # nepal (IPS1 with custom phrases)

  context "answer Iran" do
    should "give a bespoke outcome stating an application is not possible in Iran" do
      worldwide_api_has_organisations_for_location('iran', read_fixture_file('worldwide/iran_organisations.json'))
      add_response 'iran'
      assert_current_node :cannot_apply
      assert_phrase_list :body_text, [:body_iran]
    end
  end # Iran - no application outcome

  context "answer Syria" do
    should "give a bespoke outcome stating an application is not possible in Syria" do
      worldwide_api_has_organisations_for_location('syria', read_fixture_file('worldwide/syria_organisations.json'))
      add_response 'syria'
      assert_current_node :cannot_apply
      assert_phrase_list :body_text, [:body_syria]
    end
  end # Syria - no application outcome

  context "answer Cameroon, renewing, adult passport" do
    should "give the generic result with custom phrases" do
      worldwide_api_has_organisations_for_location('cameroon', read_fixture_file('worldwide/cameroon_organisations.json'))
      add_response 'cameroon'
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :ips_application_result
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_cameroon, :getting_your_passport_contact_and_id]
      assert_match /Millburngate House/, outcome_body
    end
  end # Cameroon (custom phrases)

  context "answer Kenya, applying, adult passport" do
    should "give the generic result with custom phrases" do
      worldwide_api_has_organisations_for_location('kenya', read_fixture_file('worldwide/kenya_organisations.json'))
      add_response 'kenya'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_applying_12_weeks, :how_long_it_takes_ips1]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_kenya, :getting_your_passport_contact_and_id]
      assert_state_variable :application_address, 'durham'
      assert_match /Millburngate House/, outcome_body
    end
  end # Kenya (custom phrases)

  context "answer Kenya, renewing_old, adult passport" do
    should "give the generic result with custom phrases" do
      worldwide_api_has_organisations_for_location('kenya', read_fixture_file('worldwide/kenya_organisations.json'))
      add_response 'kenya'
      add_response 'renewing_old'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_applying_12_weeks, :how_long_it_takes_ips1]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_kenya, :getting_your_passport_contact_and_id]
      assert_state_variable :application_address, 'durham'
      assert_match /Millburngate House/, outcome_body
    end
  end # Kenya (custom phrases)


  context "answer Egypt, renewing, adult passport" do
    should "give the IPS application result with custom phrases" do
      worldwide_api_has_organisations_for_location('egypt', read_fixture_file('worldwide/egypt_organisations.json'))
      add_response 'egypt'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_applying_ips1, :how_long_it_takes_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_ips1, :hmpo_1_application_form, :ips_documents_group_3]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
      assert_phrase_list :send_your_application, [:send_application_ips1_durham]
      assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
      assert_state_variable :embassy_address, nil
      assert_state_variable :supporting_documents, 'ips_documents_group_3'
      assert_match /Millburngate House/, outcome_body
    end
  end # Egypt

  context "answer Tunisia, applying, adult passport" do
    should "give the IPS application result with custom phrases" do
      worldwide_api_has_organisations_for_location('tunisia', read_fixture_file('worldwide/tunisia_organisations.json'))
      add_response 'tunisia'
      add_response 'replacing'
      add_response 'adult'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_6_weeks, :how_long_it_takes_ips2]
      assert_phrase_list :how_to_apply, [:how_to_apply_ips2, :hmpo_1_application_form, :ips_documents_group_2]
      assert_phrase_list :cost, [:passport_courier_costs_ips2, :adult_passport_costs_ips2, :passport_costs_ips_cash]
      assert_phrase_list :send_your_application, [:send_application_ips2, :send_application_embassy_address]
      assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
      assert_state_variable :supporting_documents, 'ips_documents_group_2'
      assert_match /Rue du Lac Windermere/, outcome_body
    end
  end # Tunisia

  context "answer Yemen, applying, adult passport" do
    should "give the IPS application result with custom phrases" do
      worldwide_api_has_organisations_for_location('yemen', read_fixture_file('worldwide/yemen_organisations.json'))
      add_response 'yemen'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_applying_ips1, :how_long_it_takes_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_ips1, :hmpo_1_application_form, :ips_documents_group_3]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
      assert_phrase_list :send_your_application, [:send_application_ips1_durham]
      assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
      assert_match /Millburngate House/, outcome_body
    end
  end # Yemen

  context "answer Haiti, renewing new, adult passport" do
    should "give the ips result" do
      worldwide_api_has_organisations_for_location('haiti', read_fixture_file('worldwide/haiti_organisations.json'))
      add_response 'haiti'
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :ips_application_result_online
      assert_phrase_list :how_long_it_takes, [:how_long_renewing_new_online, :how_long_additional_time_online]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_ips1]
    end
  end # Haiti

  context "answer South Africa" do
    context "applying, adult passport" do
      should "give the IPS online result" do
        worldwide_api_has_organisations_for_location('south-africa', read_fixture_file('worldwide/south-africa_organisations.json'))
        add_response 'south-africa'
        add_response 'applying'
        add_response 'adult'
        add_response 'united-kingdom'
        assert_current_node :ips_application_result_online
        assert_phrase_list :how_long_it_takes, [:how_long_applying_online, :how_long_additional_time_online]
        assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1]
        assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_applying, :how_to_apply_online_guidance_doc_group_2]
        assert_phrase_list :getting_your_passport, [:getting_your_passport_ips1]
        assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
      end
    end
    context "renewing, adult passport" do
      should "give the IPS online result" do
        worldwide_api_has_organisations_for_location('south-africa', read_fixture_file('worldwide/south-africa_organisations.json'))
        add_response 'south-africa'
        add_response 'renewing_new'
        add_response 'adult'
        assert_current_node :ips_application_result_online
        assert_phrase_list :how_long_it_takes, [:how_long_renewing_new_online, :how_long_additional_time_online]
        assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1]
        assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_renewing, :how_to_apply_online_guidance_doc_group_2]
        assert_phrase_list :getting_your_passport, [:getting_your_passport_ips1]
        assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
      end
    end
  end # South Africa (IPS online application)

  context "answer Gaza, applying, adult passport" do
    should "give the IPS application result with custom phrases" do
      worldwide_api_has_organisations_for_location('the-occupied-palestinian-territories', read_fixture_file('worldwide/the-occupied-palestinian-territories_organisations.json'))
      add_response 'the-occupied-palestinian-territories'
      add_response 'gaza'
      add_response 'replacing'
      add_response 'adult'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_replacing_ips3, :how_long_it_takes_ips3]
      assert_phrase_list :how_to_apply, [:how_to_apply_ips3, :hmpo_1_application_form, :ips_documents_group_1]
      assert_phrase_list :cost, [:passport_courier_costs_ips3, :adult_passport_costs_ips3, :passport_costs_ips_cash]
      assert_phrase_list :send_your_application, [:send_application_ips3_gaza]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_ips3]
      assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
    end
  end # Tunisia

  context "answer St Helena etc, renewing old, adult passport" do
    should "give the fco result with custom phrases" do
      worldwide_api_has_no_organisations_for_location('st-helena-ascension-and-tristan-da-cunha')
      add_response 'st-helena-ascension-and-tristan-da-cunha'
      add_response 'renewing_old'
      add_response 'adult'
      assert_current_node :fco_result
      assert_phrase_list :how_long_it_takes, [:how_long_renewing_old_fco]
      assert_phrase_list :cost, [:passport_courier_costs_pretoria_south_africa, :adult_passport_costs_pretoria_south_africa, :passport_costs_pretoria_south_africa]
      assert_match /^[\d,]+ South African Rand \| [\d,]+ South African Rand$/, current_state.costs_south_african_rand_adult_32
      assert_state_variable :supporting_documents, ''
    end
  end # St Helena (FCO with custom phrases)

  context "answer Kazakhstan, applying, child passport" do
    should "give the IPS application result with custom phrases" do
      worldwide_api_has_organisations_for_location('kazakhstan', read_fixture_file('worldwide/kazakhstan_organisations.json'))
      add_response 'kazakhstan'
      add_response 'applying'
      add_response 'child'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_applying_ips3, :how_long_it_takes_ips3]
      assert_phrase_list :cost, [:passport_courier_costs_ips3, :child_passport_costs_ips3, :passport_costs_ips3]
      assert_phrase_list :send_your_application, [:send_application_ips3, :send_application_embassy_address]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_ips3]
      assert_match /Astana 010000/, outcome_body
    end
  end # Kazakhstan

  context "answer Kyrgyzstan, renewing_old, adult passport" do
    should "give the IPS application result with custom phrases" do
      worldwide_api_has_organisations_for_location('kazakhstan', read_fixture_file('worldwide/kazakhstan_organisations.json'))
      add_response 'kyrgyzstan'
      add_response 'renewing_old'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_renewing_old_ips3, :how_long_it_takes_ips3]
      assert_phrase_list :cost, [:passport_courier_costs_ips3, :adult_passport_costs_ips3, :passport_costs_ips3]
      assert_phrase_list :send_your_application, [:send_application_ips3, :renewing_new_renewing_old, :send_application_embassy_address]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_ips3]
      assert_match /British Embassy Astana/, outcome_body
    end
  end # Kyrgyzstan

  context "answer Nigeria, applying, adult passport" do
    should "give the result with custom phrases" do
      worldwide_api_has_organisations_for_location('nigeria', read_fixture_file('worldwide/nigeria_organisations.json'))
      add_response 'nigeria'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_phrase_list :fco_forms, [:adult_fco_forms_nigeria]
      assert_phrase_list :how_long_it_takes, [:how_long_applying_ips1, :how_long_it_takes_ips1]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_ips1, :hmpo_1_application_form, :ips_documents_group_3]
      assert_phrase_list :send_your_application, [:send_application_ips1_durham]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_nigeria, :getting_your_passport_contact_and_id]
      assert_phrase_list :contact_passport_adviceline, [:contact_passport_adviceline]
    end
  end # Nigeria

  context "answer Russia, applying, child passport" do
    should "give the IPS application result with custom phrases" do
      worldwide_api_has_organisations_for_location('russia', read_fixture_file('worldwide/russia_organisations.json'))
      add_response 'russia'
      add_response 'applying'
      add_response 'child'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_8_weeks, :how_long_it_takes_ips2]
      assert_phrase_list :cost, [:passport_courier_costs_ips2, :child_passport_costs_ips2, :passport_costs_ips2]
      assert_phrase_list :send_your_application, [:send_application_ips2, :send_application_embassy_address]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_ips2]
      assert_match /British Consulate-General St Petersburg/, outcome_body
      assert_match /15A, Gogol Street/, outcome_body
      assert outcome_body.at_css("div.contact p a[href='https://www.gov.uk/government/world/organisations/british-embassy-moscow/office/british-consulate-general-st-petersburg']")
      assert outcome_body.at_css("div.contact p a[href='https://www.gov.uk/government/world/organisations/british-embassy-moscow/office/ekaterinburg-consulate-general']")

    end
  end # Russia

  context "answer Jamaica, replacement, adult passport" do
    should "give the ips result with custom phrase" do
      worldwide_api_has_organisations_for_location('jamaica', read_fixture_file('worldwide/jamaica_organisations.json'))
      add_response 'jamaica'
      add_response 'replacing'
      add_response 'adult'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_replacing_ips1, :how_long_it_takes_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_ips1, :hmpo_2_application_form, :ips_documents_group_3]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
      assert_match /Millburngate House/, outcome_body
    end
  end # Jamaica

  context "answer Zimbabwe, applying, adult passport" do
    setup do
      worldwide_api_has_organisations_for_location('zimbabwe', read_fixture_file('worldwide/zimbabwe_organisations.json'))
      add_response 'zimbabwe'
    end
    should "give the ips outcome with applying phrases" do
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_6_weeks, :how_long_it_takes_ips1]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_zimbabwe, :getting_your_passport_contact_and_id]
    end
    should "give the ips outcome with renewing_new phrases" do
      add_response 'renewing_new'
      add_response 'adult'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_renewing_new_ips1, :how_long_it_takes_ips1]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
      assert_phrase_list :send_your_application, [:send_application_ips1_durham]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_zimbabwe, :getting_your_passport_contact_and_id]
    end
    should "give the ips outcome with replacing phrases" do
      add_response 'replacing'
      add_response 'adult'
      assert_current_node :ips_application_result
      assert_phrase_list :how_long_it_takes, [:how_long_6_weeks, :how_long_it_takes_ips1]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1, :passport_costs_ips1]
      assert_phrase_list :send_your_application, [:send_application_ips1_durham]
      assert_phrase_list :getting_your_passport, [:getting_your_passport_zimbabwe, :getting_your_passport_contact_and_id]
    end
  end # Zimbabwe

  context "answer Bangladesh" do
    setup do
      worldwide_api_has_organisations_for_location('bangladesh', read_fixture_file('worldwide/bangladesh_organisations.json'))
      add_response 'bangladesh'
    end
    context "renewing a new adult passport" do
      should "give the ips result" do
        add_response 'renewing_new'
        add_response 'adult'
        assert_current_node :ips_application_result
        assert_phrase_list :how_long_it_takes, [:how_long_6_weeks, :how_long_it_takes_ips3]
        assert_phrase_list :cost, [:passport_courier_costs_ips3, :adult_passport_costs_ips3, :passport_costs_ips3_cash_or_card_bangladesh, :passport_costs_ips3_cash_or_card]
        assert_phrase_list :send_your_application, [:send_application_ips3_bangladesh, :send_application_embassy_address]
      end
    end
    context "replacing a new adult passport" do
      should "give the ips result" do
        add_response 'replacing'
        add_response 'adult'
        assert_current_node :ips_application_result
        assert_phrase_list :how_long_it_takes, [:how_long_16_weeks, :how_long_it_takes_ips3]
        assert_phrase_list :cost, [:passport_courier_costs_ips3, :adult_passport_costs_ips3, :passport_costs_ips3_cash_or_card_bangladesh, :passport_costs_ips3_cash_or_card]
      end
    end
    context "applying for a new adult passport" do
      should "give the ips result" do
        add_response 'applying'
        add_response 'adult'
        add_response 'bangladesh'
        assert_current_node :ips_application_result
        assert_phrase_list :how_long_it_takes, [:how_long_applying_at_least_6_months, :how_long_it_takes_ips3]
        assert_phrase_list :cost, [:passport_courier_costs_ips3, :adult_passport_costs_ips3, :passport_costs_ips3_cash_or_card_bangladesh, :passport_costs_ips3_cash_or_card]
      end
    end
  end # Bangladesh

  context "answer Pakistan" do
    setup do
      worldwide_api_has_organisations_for_location('pakistan', read_fixture_file('worldwide/pakistan_organisations.json'))
      add_response 'pakistan'
    end
    context "applying for a new adult passport" do
      should "give the ips result" do
        add_response 'applying'
        add_response 'adult'
        add_response 'pakistan'
        assert_current_node :ips_application_result
        assert_phrase_list :how_long_it_takes, [:how_long_applying_at_least_6_months, :how_long_it_takes_ips3]
        assert_phrase_list :send_your_application, [:send_application_ips3_pakistan, :send_application_ips3_must_post, :send_application_embassy_address]
        assert_phrase_list :how_to_apply, [:how_to_apply_ips3, :send_application_ips1_pakistan, :hmpo_1_application_form, :ips_documents_group_3]
      end
    end
  end # Pakistan

  context "answer Thailand" do
    setup do
      worldwide_api_has_organisations_for_location('thailand', read_fixture_file('worldwide/thailand_organisations.json'))
      add_response 'thailand'
    end
    context "renewing a new adult passport" do
      should "give the ips result" do
        add_response 'renewing_new'
        add_response 'adult'
        assert_current_node :ips_application_result
        assert_phrase_list :how_long_it_takes, [:how_long_renewing_new_ips3, :how_long_it_takes_ips3]
        assert_phrase_list :cost, [:passport_courier_costs_ips3_thailand_renewing_new, :adult_passport_costs_ips3_thailand_renewing_new, :passport_costs_ips3]
        assert_phrase_list :how_to_apply, [:how_to_apply_ips3, :send_colour_photocopy_bulletpoint, :hmpo_1_application_form, :ips_documents_group_2]
        assert_phrase_list :send_your_application, [:send_application_ips3_thailand_renewing_new]
        assert_phrase_list :getting_your_passport, [:getting_your_passport_thailand_renewing_new]
      end
    end
    context "applying for a new adult passport" do
      should "give the ips result" do
        add_response 'applying'
        add_response 'adult'
        add_response 'thailand'
        assert_current_node :ips_application_result
        assert_phrase_list :how_long_it_takes, [:how_long_applying_ips3, :how_long_it_takes_ips3]
        assert_phrase_list :cost, [:passport_courier_costs_ips3_thailand_apply_renew_old_replace, :adult_passport_costs_ips3, :passport_costs_ips3_cash_or_card_thailand, :passport_costs_ips3_cash_or_card]
        assert_phrase_list :how_to_apply, [:how_to_apply_ips3, :hmpo_1_application_form, :ips_documents_group_2]
        assert_phrase_list :send_your_application, [:send_application_ips3, :send_application_embassy_address]
        assert_phrase_list :getting_your_passport, [:getting_your_passport_thailand_apply_renew_old_replace]
      end
    end
  end # Thailand

  context "answer Uzbekistan" do
    setup do
      worldwide_api_has_organisations_for_location('uzbekistan', read_fixture_file('worldwide/uzbekistan_organisations.json'))
      add_response 'uzbekistan'
    end
    context "renewing a new adult passport" do
      should "give the ips result" do
        add_response 'renewing_new'
        add_response 'adult'
        assert_current_node :ips_application_result
        assert_phrase_list :how_long_it_takes, [:how_long_8_weeks, :how_long_it_takes_ips3]
        assert_phrase_list :cost, [:passport_courier_costs_ips3, :adult_passport_costs_ips3, :passport_costs_ips3]
        assert_phrase_list :how_to_apply, [:how_to_apply_ips3, :hmpo_1_application_form, :ips_documents_group_3]
        assert_phrase_list :send_your_application, [:send_application_ips3, :renewing_new_renewing_old, :send_application_embassy_address]
        assert_phrase_list :getting_your_passport, [:getting_your_passport_ips3]
      end
    end
    context "applying for a new adult passport" do
      should "give the ips result" do
        add_response 'applying'
        add_response 'adult'
        add_response 'united-kingdom'
        assert_current_node :ips_application_result
        assert_phrase_list :how_long_it_takes, [:how_long_8_weeks, :how_long_it_takes_ips3]
        assert_phrase_list :cost, [:passport_courier_costs_ips3, :adult_passport_costs_ips3, :passport_costs_ips3]
        assert_phrase_list :how_to_apply, [:how_to_apply_ips3, :hmpo_1_application_form, :ips_documents_group_3]
        assert_phrase_list :send_your_application, [:send_application_ips3, :send_application_embassy_address]
        assert_phrase_list :getting_your_passport, [:getting_your_passport_ips3]
      end
    end
  end # Uzbekistan

  context "answer Bahamas, applying, adult passport" do
    should "give the IPS online outcome" do
      worldwide_api_has_organisations_for_location('bahamas', read_fixture_file('worldwide/bahamas_organisations.json'))
      add_response 'bahamas'
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result_online
      assert_phrase_list :how_long_it_takes, [:how_long_applying_online, :how_long_additional_time_online]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_applying, :how_to_apply_online_guidance_doc_group_2]
    end
  end # Bahamas

  context "answer british-indian-ocean-territory" do
    should "go to apply_in_neighbouring_country outcome" do
      worldwide_api_has_organisations_for_location('british-indian-ocean-territory', read_fixture_file('worldwide/british-indian-ocean-territory_organisations.json'))
      add_response 'british-indian-ocean-territory'
      assert_current_node :apply_in_neighbouring_country
    end
  end # british-indian-ocean-territory
  

  
  context "answer turkey, doc group 1" do
    setup do
      worldwide_api_has_organisations_for_location('turkey', read_fixture_file('worldwide/turkey_organisations.json'))
      add_response 'turkey'
    end
    should "show how to apply online" do
      add_response 'applying'
      add_response 'adult'
      add_response 'united-kingdom'
      assert_current_node :ips_application_result_online
      assert_phrase_list :how_long_it_takes, [:how_long_applying_online, :how_long_additional_time_online]
      assert_phrase_list :cost, [:passport_courier_costs_ips1, :adult_passport_costs_ips1]
      assert_phrase_list :how_to_apply, [:how_to_apply_online, :how_to_apply_online_prerequisites_applying, :how_to_apply_online_guidance_doc_group_1]
      assert_match /the passport numbers of both parents/, outcome_body
    end
  end
end
