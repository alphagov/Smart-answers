require_relative "../../test_helper"

module SmartAnswer
  module Calculators
    class MarriageAbroadCalculatorTest < ActiveSupport::TestCase
      setup do
        MarriageAbroadDataQuery.any_instance
            .stubs(:countries_with_18_outcomes).returns(%w[18_outcome_country country])
        MarriageAbroadDataQuery.any_instance
            .stubs(:countries_with_6_outcomes).returns(%w[6_outcome_country])
        MarriageAbroadDataQuery.any_instance
            .stubs(:countries_with_2_outcomes).returns(%w[2_outcome_country])
      end

      context "#path_to_outcome" do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should "get outcome for country where: opposite_sex marriage, user lives in ceremony country, partner is local" do
          @calculator.ceremony_country = "country"
          @calculator.resident_of = "ceremony_country"
          @calculator.partner_nationality = "partner_local"
          @calculator.sex_of_your_partner = "opposite_sex"

          assert_equal %w[country ceremony_country partner_local opposite_sex], @calculator.path_to_outcome
        end

        should "get outcome for country where: same_sex marriage, user lives in uk, partner is british" do
          @calculator.ceremony_country = "country"
          @calculator.resident_of = "uk"
          @calculator.partner_nationality = "partner_british"
          @calculator.sex_of_your_partner = "same_sex"

          assert_equal %w[country uk partner_british same_sex], @calculator.path_to_outcome
        end

        should "get outcome for country where: same_sex marriage, user lives in another country, partner is from another country" do
          @calculator.ceremony_country = "country"
          @calculator.resident_of = "third_country"
          @calculator.partner_nationality = "partner_other"
          @calculator.sex_of_your_partner = "same_sex"

          assert_equal %w[country third_country partner_other same_sex], @calculator.path_to_outcome
        end

        should "get opposite-sex outcome for 2 outcome country" do
          @calculator.ceremony_country = "2_outcome_country"
          @calculator.sex_of_your_partner = "opposite_sex"

          assert_equal %w[2_outcome_country opposite_sex], @calculator.path_to_outcome
        end

        should "get same-sex outcome for 2 outcome country" do
          @calculator.ceremony_country = "2_outcome_country"
          @calculator.sex_of_your_partner = "same_sex"

          assert_equal %w[2_outcome_country same_sex], @calculator.path_to_outcome
        end

        context "country offers opposite sex civil partnership" do
          setup do
            MarriageAbroadDataQuery.any_instance
                .stubs(:offers_consular_opposite_sex_civil_partnership?).returns(%w[country])
          end

          should "get outcome for consular civil partnership countries for opposite sex civil partnership" do
            @calculator.ceremony_country = "country"
            @calculator.sex_of_your_partner = "opposite_sex"
            @calculator.type_of_ceremony = "civil_partnership"

            assert_equal %w[country opposite_sex_civil_partnership], @calculator.path_to_outcome
          end

          should "get outcome for consular civil partnership countries for opposite sex marriage" do
            @calculator.ceremony_country = "2_outcome_country"
            @calculator.sex_of_your_partner = "opposite_sex"
            @calculator.type_of_ceremony = "marriage"

            assert_equal %w[2_outcome_country opposite_sex], @calculator.path_to_outcome
          end
        end

        context "when ceremony country is a three questions country" do
          setup do
            MarriageAbroadDataQuery.any_instance
              .stubs(:countries_with_6_outcomes).returns(%w[6_outcome_country])
            @calculator.ceremony_country = "6_outcome_country"
          end

          should "get outcome for opposite sex in ceremony country where marriage is between opposite sex partners, user is resident and getting married in ceremony country" do
            @calculator.resident_of = "ceremony_country"
            @calculator.sex_of_your_partner = "opposite_sex"

            assert_equal %w[6_outcome_country ceremony_country opposite_sex], @calculator.path_to_outcome
          end

          should "get outcome for same sex in ceremony country where marriage is between same sex partners, user is resident and getting married in ceremony country" do
            @calculator.resident_of = "ceremony_country"
            @calculator.sex_of_your_partner = "same_sex"

            assert_equal %w[6_outcome_country ceremony_country same_sex], @calculator.path_to_outcome
          end

          should "get outcome for opposite sex in third country where marriage is between opposite sex partners, user is resident and getting married in third country" do
            @calculator.resident_of = "third_country"
            @calculator.sex_of_your_partner = "opposite_sex"

            assert_equal %w[6_outcome_country third_country opposite_sex], @calculator.path_to_outcome
          end

          should "get outcome for same sex in third country where marriage is between same sex partners, user is resident and getting married in third country" do
            @calculator.resident_of = "third_country"
            @calculator.sex_of_your_partner = "same_sex"

            assert_equal %w[6_outcome_country third_country same_sex], @calculator.path_to_outcome
          end

          should "get outcome for opposite sex in UK where marriage is between opposite sex partners, user is resident and getting married in UK" do
            @calculator.resident_of = "uk"
            @calculator.sex_of_your_partner = "opposite_sex"

            assert_equal %w[6_outcome_country uk opposite_sex], @calculator.path_to_outcome
          end

          should "get outcome for same sex in UK where marriage is between same sex partners, user is resident and getting married in UK" do
            @calculator.resident_of = "uk"
            @calculator.sex_of_your_partner = "same_sex"

            assert_equal %w[6_outcome_country uk same_sex], @calculator.path_to_outcome
          end
        end
      end

      context "#partner_british?" do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should "be true if partner is british" do
          @calculator.partner_nationality = "partner_british"
          assert @calculator.partner_british?
        end

        should "be false if partner is not british" do
          @calculator.partner_nationality = "not-partner_british"
          assert_not @calculator.partner_british?
        end
      end

      context "#partner_is_national_of_ceremony_country?" do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should "be true if partner is a national of the ceremony country" do
          @calculator.partner_nationality = "partner_local"
          assert @calculator.partner_is_national_of_ceremony_country?
        end

        should "be false if partner is not a national of the ceremony country" do
          @calculator.partner_nationality = "not-partner_local"
          assert_not @calculator.partner_is_national_of_ceremony_country?
        end
      end

      context "#resident_of_uk?" do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should "be true if resident of uk" do
          @calculator.resident_of = "uk"
          assert @calculator.resident_of_uk?
        end

        should "be false if not a resident of uk" do
          @calculator.resident_of = "not-uk"
          assert_not @calculator.resident_of_uk?
        end
      end

      context "#resident_of_ceremony_country?" do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should "be true if resident of ceremony country" do
          @calculator.resident_of = "ceremony_country"
          assert @calculator.resident_of_ceremony_country?
        end

        should "be false if not resident of ceremony country" do
          @calculator.resident_of = "not-ceremony_country"
          assert_not @calculator.resident_of_ceremony_country?
        end
      end

      context "#resident_of_third_country?" do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should "be true if resident of third country" do
          @calculator.resident_of = "third_country"
          assert @calculator.resident_of_third_country?
        end

        should "be false if not resident of third country" do
          @calculator.resident_of = "not-third_country"
          assert_not @calculator.resident_of_third_country?
        end
      end

      context "#resident_outside_of_third_country?" do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should 'be true if resident_of != "third_country"' do
          @calculator.resident_of = "not-third_country"
          assert @calculator.resident_outside_of_third_country?
        end

        should 'be false if resident_of == "third_country"' do
          @calculator.resident_of = "third_country"
          assert_not @calculator.resident_outside_of_third_country?
        end
      end

      context "#partner_is_opposite_sex?" do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should "be true when partner is of the opposite sex" do
          @calculator.sex_of_your_partner = "opposite_sex"
          assert @calculator.partner_is_opposite_sex?
        end

        should "be false when partner is not of the opposite sex" do
          @calculator.sex_of_your_partner = "not-opposite_sex"
          assert_not @calculator.partner_is_opposite_sex?
        end
      end

      context "#partner_is_same_sex?" do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should "be true when partner is of the same sex" do
          @calculator.sex_of_your_partner = "same_sex"
          assert @calculator.partner_is_same_sex?
        end

        should "be false when partner is not of the same sex" do
          @calculator.sex_of_your_partner = "not-same_sex"
          assert_not @calculator.partner_is_same_sex?
        end
      end

      context "#want_to_get_married?" do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should "be true when the couple want to get married" do
          @calculator.marriage_or_pacs = "marriage"
          assert @calculator.want_to_get_married?
        end

        should "be false when the couple don't want to get married" do
          @calculator.marriage_or_pacs = "not-marriage"
          assert_not @calculator.want_to_get_married?
        end
      end

      context "#world_location" do
        should "return the world location for the given ceremony country" do
          stub_worldwide_api_has_location("world-location")
          @calculator = MarriageAbroadCalculator.new
          @calculator.ceremony_country = "world-location"

          assert_equal "world-location", @calculator.world_location.slug
        end
      end

      context "#valid_ceremony_country?" do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should "return true if the world location can be found" do
          @calculator.stubs(:world_location).returns(stub("world-location"))

          assert @calculator.valid_ceremony_country?
        end

        should "return false if the world location cannot be found" do
          @calculator.stubs(:world_location).returns(nil)

          assert_not @calculator.valid_ceremony_country?
        end
      end

      context "#fco_organisation" do
        setup do
          stub_worldwide_api_has_location("world-location")
          @calculator = MarriageAbroadCalculator.new
          @calculator.ceremony_country = "world-location"
        end

        should "return the fco organisation for the world location" do
          organisations_data = [
            {
              "title" => "organisation-1-title",
              "base_path" => "/world/organisations/organisation-1",
            },
            {
              "title" => "organisation-2-title",
              "base_path" => "/world/organisations/organisation-2",
              "links" => {
                "sponsoring_organisations" => [
                  {
                    "details" => {
                      "acronym" => "FCDO",
                    },
                  },
                ],
              },
            },
          ]
          stub_search_api_has_organisations_for_location("world-location", organisations_data)

          assert_equal "organisation-2-title", @calculator.fco_organisation.title
        end

        should "return nil if the world location doesn't have an fco organisation" do
          stub_search_api_has_organisations_for_location("world-location", [])
          assert_nil @calculator.fco_organisation
        end
      end

      context "#overseas_passports_embassies" do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should "return the offices that offer registrations of marriage and civil partnerships" do
          world_office = stub("World Office")
          organisation = stub.quacks_like(WorldwideOrganisation.new({}))
          organisation.stubs(:offices_with_service).with("Registrations of Marriage and Civil Partnerships").returns([world_office])
          @calculator.stubs(fco_organisation: organisation)

          assert_equal [world_office], @calculator.overseas_passports_embassies
        end

        should "return an empty array when there is no fco organisation" do
          @calculator.stubs(fco_organisation: nil)

          assert_equal [], @calculator.overseas_passports_embassies
        end
      end

      context "#marriage_and_partnership_phrases" do
        setup do
          @data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          @data_query.stubs(
            ss_marriage_countries?: false,
            ss_marriage_countries_when_couple_british?: false,
            ss_marriage_and_partnership?: false,
          )
          @calculator = MarriageAbroadCalculator.new(data_query: @data_query)
        end

        should "return ss_marriage when the ceremony country is in the list of same sex marriage countries" do
          @calculator.ceremony_country = "same-sex-marriage-country"
          @data_query.stubs(:ss_marriage_countries?).with("same-sex-marriage-country").returns(true)

          assert_equal "ss_marriage", @calculator.marriage_and_partnership_phrases
        end

        should "return ss_marriage when the ceremony country is in the list of same sex marriage countries for british couples" do
          @calculator.ceremony_country = "same-sex-marriage-country-for-british-couple"
          @data_query.stubs(:ss_marriage_countries_when_couple_british?).with("same-sex-marriage-country-for-british-couple").returns(true)

          assert_equal "ss_marriage", @calculator.marriage_and_partnership_phrases
        end

        should "return ss_marriage_and_partnership when the ceremony country is in the list of same sex marriage and partnership countries" do
          @calculator.ceremony_country = "same-sex-marriage-and-partnership-country"
          @data_query.stubs(:ss_marriage_and_partnership?).with("same-sex-marriage-and-partnership-country").returns(true)

          assert_equal "ss_marriage_and_partnership", @calculator.marriage_and_partnership_phrases
        end
      end

      context "#ceremony_country_name" do
        should "return the name of the world location associated with the ceremony country" do
          stub_worldwide_api_has_location("world-location-name")
          world_location = WorldLocation.find("world-location-name")
          calculator = MarriageAbroadCalculator.new
          calculator.ceremony_country = "world-location-name"

          assert_equal world_location.name, calculator.ceremony_country_name
        end
      end

      context "#country_name_lowercase_prefix" do
        setup do
          @country_name_formatter = stub.quacks_like(CountryNameFormatter.new)
          @calculator = MarriageAbroadCalculator.new(country_name_formatter: @country_name_formatter)
          @calculator.ceremony_country = "country-slug"
        end

        should "return the definitive article if ceremony country is in the list of countries with definitive article" do
          @country_name_formatter.stubs(:requires_definite_article?).with("country-slug").returns(true)
          @country_name_formatter.stubs(:definitive_article).with("country-slug").returns("the-country-name")

          assert_equal "the-country-name", @calculator.country_name_lowercase_prefix
        end

        should "return the friendly country name if definitive article not required and friendly country name found" do
          @country_name_formatter.stubs(:requires_definite_article?).with("country-slug").returns(false)
          @country_name_formatter.stubs(:has_friendly_name?).with("country-slug").returns(true)
          @country_name_formatter.stubs(:friendly_name).with("country-slug").returns("friendly-country-name")

          assert_equal "friendly-country-name", @calculator.country_name_lowercase_prefix
        end

        should "return an html safe version of the friendly country name" do
          @country_name_formatter.stubs(:requires_definite_article?).with("country-slug").returns(false)
          @country_name_formatter.stubs(:has_friendly_name?).with("country-slug").returns(true)
          @country_name_formatter.stubs(:friendly_name).with("country-slug").returns("friendly-country-name")

          assert @calculator.country_name_lowercase_prefix.html_safe?
        end

        should "return the ceremony country name if not in the list of definitive articles or friendly country names" do
          @country_name_formatter.stubs(:requires_definite_article?).with("country-slug").returns(false)
          @country_name_formatter.stubs(:has_friendly_name?).with("country-slug").returns(false)
          @calculator.stubs(ceremony_country_name: "country-name")

          assert_equal "country-name", @calculator.country_name_lowercase_prefix
        end
      end

      context "#country_name_uppercase_prefix" do
        setup do
          @country_name_formatter = stub.quacks_like(CountryNameFormatter.new)
          @calculator = MarriageAbroadCalculator.new(country_name_formatter: @country_name_formatter)
          @calculator.ceremony_country = "country-slug"
        end

        should "return the ceremony country with upper case definite article" do
          @country_name_formatter.stubs(:definitive_article)
                                 .with("country-slug", capitalised: true)
                                 .returns("The-country-name")

          assert_equal "The-country-name", @calculator.country_name_uppercase_prefix
        end
      end

      context "#country_name_partner_residence" do
        setup do
          @data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          @data_query.stubs(
            british_overseas_territories?: false,
            french_overseas_territories?: false,
            dutch_caribbean_islands?: false,
          )

          @calculator = MarriageAbroadCalculator.new(data_query: @data_query)
          @calculator.ceremony_country = "country-slug"
        end

        should 'return "British (overseas territories citizen)" when ceremony country is British overseas territory' do
          @data_query.stubs(:british_overseas_territories?).with("country-slug").returns(true)

          assert_equal "British (overseas territories citizen)", @calculator.country_name_partner_residence
        end

        should 'return "French" when ceremony country is French overseas territory' do
          @data_query.stubs(:french_overseas_territories?).with("country-slug").returns(true)

          assert_equal "French", @calculator.country_name_partner_residence
        end

        should 'return "Dutch" when ceremony country is in the Dutch Caribbean islands' do
          @data_query.stubs(:dutch_caribbean_islands?).with("country-slug").returns(true)

          assert_equal "Dutch", @calculator.country_name_partner_residence
        end

        should 'return "Chinese" when ceremony country is Hong Kong' do
          @calculator.ceremony_country = "hong-kong"

          assert_equal "Chinese", @calculator.country_name_partner_residence
        end

        should 'return "Chinese" when ceremony country is Macao' do
          @calculator.ceremony_country = "macao"

          assert_equal "Chinese", @calculator.country_name_partner_residence
        end

        should 'return "National of <country_name_lowercase_prefix>" in all other cases' do
          @calculator.stubs(country_name_lowercase_prefix: "country-name-lowercase-prefix")

          assert_equal "National of country-name-lowercase-prefix", @calculator.country_name_partner_residence
        end
      end

      context "#embassy_or_consulate_ceremony_country" do
        setup do
          @consulate_data_query = stub.quacks_like(ConsulateDataQuery.new)
          @consulate_data_query.stubs(
            has_consulate?: false,
            has_consulate_general?: false,
          )

          @calculator = MarriageAbroadCalculator.new(consulate_data_query: @consulate_data_query)
          @calculator.ceremony_country = "country-slug"
        end

        should 'return "consulate" if ceremony country has consulate' do
          @consulate_data_query.stubs(:has_consulate?).with("country-slug").returns(true)

          assert_equal "consulate", @calculator.embassy_or_consulate_ceremony_country
        end

        should 'return "consulate" if ceremony country has consulate general' do
          @consulate_data_query.stubs(:has_consulate_general?).with("country-slug").returns(true)

          assert_equal "consulate", @calculator.embassy_or_consulate_ceremony_country
        end

        should 'return "embassy" if ceremony country has neither consulate nor consulate general' do
          assert_equal "embassy", @calculator.embassy_or_consulate_ceremony_country
        end
      end

      context "#ceremony_country_is_french_overseas_territory?" do
        should "delegate to the data query" do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          data_query.stubs(:french_overseas_territories?).with("ceremony-country").returns("french-overseas-territory")
          calculator = MarriageAbroadCalculator.new(data_query:)
          calculator.ceremony_country = "ceremony-country"

          assert_equal "french-overseas-territory", calculator.ceremony_country_is_french_overseas_territory?
        end
      end

      context "#ceremony_country_is_british_overseas_territory?" do
        should "delegate to the data query" do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          data_query.stubs(:british_overseas_territories?).with("ceremony-country").returns("british-overseas-territory")
          calculator = MarriageAbroadCalculator.new(data_query:)
          calculator.ceremony_country = "ceremony-country"

          assert_equal "british-overseas-territory", calculator.ceremony_country_is_british_overseas_territory?
        end
      end

      context "#same_sex_marriage_country?" do
        should "delegate to the data query" do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          data_query.stubs(:ss_marriage_countries?).with("ceremony-country").returns("same-sex-marriage-country")
          calculator = MarriageAbroadCalculator.new(data_query:)
          calculator.ceremony_country = "ceremony-country"

          assert_equal "same-sex-marriage-country", calculator.same_sex_marriage_country?
        end
      end

      context "#same_sex_marriage_country_when_couple_british?" do
        should "delegate to the data query" do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          data_query.stubs(:ss_marriage_countries_when_couple_british?).with("ceremony-country").returns("same-sex-marriage-country-when-couple-british")
          calculator = MarriageAbroadCalculator.new(data_query:)
          calculator.ceremony_country = "ceremony-country"

          assert_equal "same-sex-marriage-country-when-couple-british", calculator.same_sex_marriage_country_when_couple_british?
        end
      end

      context "#same_sex_marriage_and_civil_partnership?" do
        should "delegate to the data query" do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          data_query.stubs(:ss_marriage_and_partnership?).with("ceremony-country").returns("same-sex-marriage-and-civil-partnership")
          calculator = MarriageAbroadCalculator.new(data_query:)
          calculator.ceremony_country = "ceremony-country"

          assert_equal "same-sex-marriage-and-civil-partnership", calculator.same_sex_marriage_and_civil_partnership?
        end
      end

      context "country_without_consular_facilities?" do
        should "delegate to the data query" do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          data_query.stubs(:countries_without_consular_facilities?).with("ceremony-country").returns("country-without-consular-facilities")
          calculator = MarriageAbroadCalculator.new(data_query:)
          calculator.ceremony_country = "ceremony-country"

          assert_equal "country-without-consular-facilities", calculator.country_without_consular_facilities?
        end
      end

      context "ceremony_country_is_dutch_caribbean_island?" do
        should "delegate to the data query" do
          data_query = stub.quacks_like(MarriageAbroadDataQuery.new)
          data_query.stubs(:dutch_caribbean_islands?).with("ceremony-country").returns("dutch-caribbean-island")
          calculator = MarriageAbroadCalculator.new(data_query:)
          calculator.ceremony_country = "ceremony-country"

          assert_equal "dutch-caribbean-island", calculator.ceremony_country_is_dutch_caribbean_island?
        end
      end

      context "#consular_fee" do
        setup do
          consular_fees = { fee: 55 }
          rates_query = stub(rates: consular_fees)

          @calculator = MarriageAbroadCalculator.new(rates_query:)
        end

        should "return the fee value for a consular service" do
          assert_equal 55, @calculator.consular_fee(:fee)
        end

        should "return nil for an unknown consular service" do
          assert_nil @calculator.consular_fee(:invalid)
        end
      end

      context "#services" do
        setup do
          services_data = {
            "albania" => {
              "default" => [:default_service],
              "opposite_sex" => {
                "default" => {
                  "default" => [:partner_sex_specific_default_service],
                  "partner_local" => [:partner_sex_and_nationality_specific_service],
                },
                "uk" => {
                  "default" => [:residency_specific_default_service],
                  "partner_local" => [:residency_and_nationality_specific_service],
                },
              },
            },
          }
          @calculator = MarriageAbroadCalculator.new(services_data:)
        end

        should "return empty array if country not found in data" do
          @calculator.ceremony_country = "country-not-in-data"

          assert_equal [], @calculator.services
        end

        should "return default services if country found but no services available for type of ceremony" do
          @calculator.ceremony_country = "albania"
          @calculator.sex_of_your_partner = "same_sex"

          assert_equal [:default_service], @calculator.services
        end

        should "return default services matching the country if sex of partner is not defined" do
          @calculator.ceremony_country = "albania"

          assert_equal [:default_service], @calculator.services
        end

        should "return default services matching the country and sex of partner" do
          @calculator.ceremony_country = "albania"
          @calculator.sex_of_your_partner = "opposite_sex"

          assert_equal [:partner_sex_specific_default_service], @calculator.services
        end

        should "return default services matching the country, sex of partner and residency" do
          @calculator.ceremony_country = "albania"
          @calculator.sex_of_your_partner = "opposite_sex"
          @calculator.resident_of = "uk"

          assert_equal [:residency_specific_default_service], @calculator.services
        end

        should "return services matching the country, sex of partner, default residency and nationality of partner" do
          @calculator.ceremony_country = "albania"
          @calculator.sex_of_your_partner = "opposite_sex"
          @calculator.partner_nationality = "partner_local"

          assert_equal [:partner_sex_and_nationality_specific_service], @calculator.services
        end

        should "return services matching the country, sex of partner, residency and nationality of partner" do
          @calculator.ceremony_country = "albania"
          @calculator.sex_of_your_partner = "opposite_sex"
          @calculator.resident_of = "uk"
          @calculator.partner_nationality = "partner_local"

          assert_equal [:residency_and_nationality_specific_service], @calculator.services
        end
      end

      context "#ceremony_country_offers_pacs?" do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should "return true if a PACS is available in the ceremony country" do
          @calculator.ceremony_country = "monaco"
          assert @calculator.ceremony_country_offers_pacs?
        end

        should "return false if a PACS is not available in the ceremony country" do
          @calculator.ceremony_country = "country-without-pacs"
          assert_not @calculator.ceremony_country_offers_pacs?
        end
      end

      context "#offers_consular_opposite_sex_civil_partnership?" do
        setup do
          @calculator = MarriageAbroadCalculator.new
        end

        should "return true if a consular opposite sex civil partnership is available in the ceremony country" do
          @calculator.ceremony_country = "japan"
          assert @calculator.offers_consular_opposite_sex_civil_partnership?
        end

        should "return false if a consular opposite sex civil partnership is not available in the ceremony country" do
          @calculator.ceremony_country = "country-without-pacs"
          assert_not @calculator.offers_consular_opposite_sex_civil_partnership?
        end
      end

      context "#services_payment_partial_name" do
        should "return nil if there's no data for the ceremony country" do
          calculator = MarriageAbroadCalculator.new(services_data: {})
          calculator.ceremony_country = "ceremony-country"

          assert_nil calculator.services_payment_partial_name
        end

        should "return nil if there's no payment information partial set for the ceremony country" do
          services_data = { "ceremony-country" => {} }
          calculator = MarriageAbroadCalculator.new(services_data:)
          calculator.ceremony_country = "ceremony-country"

          assert_nil calculator.services_payment_partial_name
        end

        should "return the name of the country payment information partial" do
          services_data = {
            "ceremony-country" => {
              "payment_partial_name" => "partial-name",
            },
          }
          calculator = MarriageAbroadCalculator.new(services_data:)
          calculator.ceremony_country = "ceremony-country"

          assert_equal "partial-name", calculator.services_payment_partial_name
        end

        should "return the name of the countries marriage type payment information partial" do
          services_data = {
            "ceremony-country" => {
              "opposite_sex" => { "payment_partial_name" => "partial-name" },
            },
          }
          calculator = MarriageAbroadCalculator.new(services_data:)
          calculator.ceremony_country = "ceremony-country"

          assert_equal "partial-name", calculator.services_payment_partial_name
        end
      end

      context "outcome per path" do
        context "#two_questions_country?" do
          should "return true if this 2 outcome country is part of the outcome per path countries" do
            @calculator = MarriageAbroadCalculator.new
            @calculator.ceremony_country = "2_outcome_country"

            assert_equal true, @calculator.has_outcome_per_path?
          end

          should "return true if country has two questions" do
            @calculator = MarriageAbroadCalculator.new
            @calculator.ceremony_country = "2_outcome_country"

            assert_equal true, @calculator.two_questions_country?
          end
        end

        context "#three_questions_country?" do
          should "return true if this 6 outcome country is part of the outcome per path countries" do
            @calculator = MarriageAbroadCalculator.new
            @calculator.ceremony_country = "6_outcome_country"

            assert_equal true, @calculator.has_outcome_per_path?
          end

          should "return true if country has three questions" do
            @calculator = MarriageAbroadCalculator.new
            @calculator.ceremony_country = "6_outcome_country"

            assert_equal true, @calculator.three_questions_country?
          end
        end

        context "#four_questions_country?" do
          should "return true if this 18 outcome country is part of the outcome per path countries" do
            @calculator = MarriageAbroadCalculator.new
            @calculator.ceremony_country = "18_outcome_country"

            assert_equal true, @calculator.has_outcome_per_path?
          end

          should "return true if country has three questions" do
            @calculator = MarriageAbroadCalculator.new
            @calculator.ceremony_country = "18_outcome_country"

            assert_equal true, @calculator.four_questions_country?
          end
        end
      end
    end
  end
end
