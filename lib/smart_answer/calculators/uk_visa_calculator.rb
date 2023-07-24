module SmartAnswer::Calculators
  class UkVisaCalculator
    include ActiveModel::Model

    attr_writer :passport_country,
                :purpose_of_visit_answer,
                :travelling_to_cta_answer,
                :passing_through_uk_border_control_answer,
                :travel_document_type,
                :travelling_visiting_partner_family_member_answer,
                :length_of_stay

    attr_accessor :what_type_of_work

    OUTCOME_DATA = YAML.load_file(Rails.root.join("config/smart_answers/check_uk_visa_data.yml")).freeze

    def outcome_title
      OUTCOME_DATA.dig("work_types", @what_type_of_work, "title")
    end

    def potential_visas
      visa_names = OUTCOME_DATA.dig("work_types", @what_type_of_work, "potential_visas")

      visa_names.flat_map do |name|
        OUTCOME_DATA["visas"].select do |visa|
          visa["name"] == name
        end
      end
    end

    def visas_for_outcome
      potential_visas.select { |visa|
        visa["condition"].nil? || send(visa["condition"])
      }.compact
    end

    def visa_types_for_outcome
      visas_for_outcome.map { |visa| visa["name"] }
    end

    def number_of_visas_for_outcome
      @number_of_visas_for_outcome ||= visas_for_outcome.count
    end

    def visa_attribute_statement(attribute_title)
      OUTCOME_DATA.dig("consts", attribute_title)
    end

    def passport_country_in_eea?
      COUNTRY_GROUP_EEA.include?(@passport_country)
    end

    def passport_country_in_non_visa_national_list?
      COUNTRY_GROUP_NON_VISA_NATIONAL.include?(@passport_country)
    end

    def passport_country_in_visa_national_list?
      COUNTRY_GROUP_VISA_NATIONAL.include?(@passport_country)
    end

    def passport_country_in_british_overseas_territories_list?
      COUNTRY_GROUP_BRITISH_OVERSEAS_TERRITORIES.include?(@passport_country)
    end

    def passport_country_in_direct_airside_transit_visa_list?
      COUNTRY_GROUP_DIRECT_AIRSIDE_TRANSIT_VISA.include?(@passport_country)
    end

    def passport_country_in_youth_mobility_scheme_list?
      COUNTRY_GROUP_YOUTH_MOBILITY_SCHEME.include?(@passport_country)
    end

    def passport_country_in_uk_ancestry_visa_list?
      COUNTRY_GROUP_UK_ANCESTRY_VISA.include?(@passport_country)
    end

    def passport_country_in_electronic_visa_waiver_list?
      COUNTRY_GROUP_ELECTRONIC_VISA_WAIVER.include?(@passport_country)
    end

    def passport_country_in_electronic_travel_authorisation_list?
      %w[qatar].include?(@passport_country)
    end

    def passport_country_in_epassport_gate_list?
      COUNTRY_GROUP_EPASSPORT_GATES.include?(@passport_country)
    end

    def passport_country_in_british_national_overseas_list?
      COUNTRY_GROUP_BRITISH_NATIONAL_OVERSEAS.include?(@passport_country)
    end

    def passport_country_in_b1_b2_visa_exception_list?
      @passport_country == "syria"
    end

    def passport_country_is_israel?
      @passport_country == "israel"
    end

    def passport_country_is_taiwan?
      @passport_country == "taiwan"
    end

    def passport_country_is_venezuela?
      @passport_country == "venezuela"
    end

    def passport_country_is_croatia?
      @passport_country == "croatia"
    end

    def passport_country_is_china?
      @passport_country == "china"
    end

    def passport_country_is_estonia?
      @passport_country == "estonia" || @passport_country == "estonia-alien-passport"
    end

    def passport_country_is_hong_kong?
      @passport_country == "hong-kong"
    end

    def passport_country_is_ireland?
      @passport_country == "ireland"
    end

    def passport_country_is_latvia?
      @passport_country == "latvia" || @passport_country == "latvia-alien-passport"
    end

    def passport_country_is_macao?
      @passport_country == "macao"
    end

    def passport_country_is_turkey?
      @passport_country == "turkey"
    end

    def applicant_is_stateless_or_a_refugee?
      @passport_country == "stateless-or-refugee"
    end

    def travel_document?
      @travel_document_type == "travel_document"
    end

    def tourism_visit?
      @purpose_of_visit_answer == "tourism"
    end

    def work_visit?
      @purpose_of_visit_answer == "work"
    end

    def study_visit?
      @purpose_of_visit_answer == "study"
    end

    def transit_visit?
      @purpose_of_visit_answer == "transit"
    end

    def family_visit?
      @purpose_of_visit_answer == "family"
    end

    def marriage_visit?
      @purpose_of_visit_answer == "marriage"
    end

    def school_visit?
      @purpose_of_visit_answer == "school"
    end

    def medical_visit?
      @purpose_of_visit_answer == "medical"
    end

    def diplomatic_visit?
      @purpose_of_visit_answer == "diplomatic"
    end

    def passing_through_uk_border_control?
      @passing_through_uk_border_control_answer == "yes"
    end

    def travelling_to_channel_islands_or_isle_of_man?
      @travelling_to_cta_answer == "channel_islands_or_isle_of_man"
    end

    def travelling_to_ireland?
      @travelling_to_cta_answer == "republic_of_ireland"
    end

    def travelling_to_elsewhere?
      @travelling_to_cta_answer == "somewhere_else"
    end

    def travelling_visiting_partner_family_member?
      @travelling_visiting_partner_family_member_answer == "yes"
    end

    def study_or_work
      if study_visit?
        "study"
      elsif work_visit?
        "work"
      end
    end

    def staying_for_over_six_months?
      @length_of_stay == "longer_than_six_months"
    end

    def staying_for_six_months_or_less?
      @length_of_stay == "six_months_or_less"
    end

    def eligible_for_secondment_visa?
      work_visit? && staying_for_over_six_months? && @what_type_of_work == "other"
    end

    def eligible_for_india_young_professionals_scheme?
      @passport_country == "india" && work_visit? && staying_for_over_six_months? && @what_type_of_work != "sports"
    end

    def july_19_to_august_16_2023_grace_period_country?
      %w[
        dominica
        honduras
        namibia
        timor-leste
        vanuatu
      ].freeze.include?(@passport_country)
    end

    EXCLUDE_COUNTRIES = %w[
      american-samoa
      british-antarctic-territory
      british-indian-ocean-territory
      french-guiana
      french-polynesia
      gibraltar
      guadeloupe
      holy-see
      martinique
      mayotte
      new-caledonia
      reunion
      st-pierre-and-miquelon
      the-occupied-palestinian-territories
      wallis-and-futuna
      western-sahara
    ].freeze

    COUNTRY_GROUP_COMMONWEALTH = %w[
      antigua-and-barbuda
      australia
      bahamas
      bangladesh
      barbados
      belize
      botswana
      brunei
      cameroon
      canada
      cyprus
      dominica
      eswatini
      fiji
      ghana
      grenada
      guyana
      india
      jamaica
      kenya
      kiribati
      lesotho
      malawi
      malaysia
      maldives
      malta
      mauritius
      mozambique
      namibia
      nauru
      new-zealand
      nigeria
      pakistan
      papua-new-guinea
      rwanda
      samoa
      seychelles
      sierra-leone
      singapore
      solomon-islands
      south-africa
      sri-lanka
      st-kitts-and-nevis
      st-lucia
      st-vincent-and-the-grenadines
      tanzania
      the-gambia
      tonga
      trinidad-and-tobago
      tuvalu
      uganda
      vanuatu
      zambia
    ].freeze

    COUNTRY_GROUP_BRITISH_OVERSEAS_TERRITORIES = %w[
      anguilla
      bermuda
      british-dependent-territories-citizen
      british-overseas-citizen
      british-protected-person
      british-virgin-islands
      cayman-islands
      falkland-islands
      montserrat
      south-georgia-and-the-south-sandwich-islands
      st-helena-ascension-and-tristan-da-cunha
      turks-and-caicos-islands
    ].freeze

    COUNTRY_GROUP_NON_VISA_NATIONAL = %w(
      andorra
      antigua-and-barbuda
      argentina
      aruba
      australia
      bahamas
      barbados
      belize
      bonaire-st-eustatius-saba
      botswana
      brazil
      british-national-overseas
      brunei
      canada
      chile
      colombia
      costa-rica
      curacao
      grenada
      guatemala
      guyana
      hong-kong
      hong-kong-(british-national-overseas)
      israel
      japan
      kiribati
      macao
      malaysia
      maldives
      marshall-islands
      mauritius
      mexico
      micronesia
      monaco
      nauru
      new-zealand
      nicaragua
      palau
      panama
      papua-new-guinea
      paraguay
      peru
      pitcairn-island
      samoa
      san-marino
      seychelles
      singapore
      solomon-islands
      south-korea
      st-kitts-and-nevis
      st-lucia
      st-maarten
      st-vincent-and-the-grenadines
      tonga
      trinidad-and-tobago
      tuvalu
      uruguay
      usa
      vatican-city
    ).freeze

    COUNTRY_GROUP_VISA_NATIONAL = %w[
      armenia
      azerbaijan
      bahrain
      benin
      bhutan
      bolivia
      bosnia-and-herzegovina
      burkina-faso
      cambodia
      cape-verde
      central-african-republic
      chad
      comoros
      cuba
      djibouti
      dominican-republic
      ecuador
      equatorial-guinea
      fiji
      gabon
      georgia
      haiti
      indonesia
      jordan
      kazakhstan
      kuwait
      kyrgyzstan
      laos
      madagascar
      mali
      mauritania
      montenegro
      morocco
      mozambique
      niger
      north-korea
      oman
      philippines
      qatar
      russia
      sao-tome-and-principe
      saudi-arabia
      stateless-or-refugee
      suriname
      taiwan
      tajikistan
      thailand
      togo
      tunisia
      turkmenistan
      ukraine
      united-arab-emirates
      uzbekistan
      zambia
    ].freeze

    COUNTRY_GROUP_DIRECT_AIRSIDE_TRANSIT_VISA = %w[
      afghanistan
      albania
      algeria
      angola
      bangladesh
      belarus
      burundi
      cameroon
      china
      congo
      cote-d-ivoire
      cyprus-north
      democratic-republic-of-the-congo
      dominica
      egypt
      el-salvador
      eritrea
      estonia-alien-passport
      eswatini
      ethiopia
      ghana
      guinea
      guinea-bissau
      honduras
      india
      iran
      iraq
      israel-provisional-passport
      jamaica
      kenya
      kosovo
      latvia-alien-passport
      lebanon
      lesotho
      liberia
      libya
      malawi
      moldova
      mongolia
      myanmar
      namibia
      nepal
      nigeria
      north-macedonia
      pakistan
      palestinian-territories
      rwanda
      senegal
      serbia
      sierra-leone
      somalia
      south-africa
      south-sudan
      sri-lanka
      sudan
      syria
      tanzania
      the-gambia
      timor-leste
      turkey
      uganda
      vanuatu
      venezuela
      vietnam
      yemen
      zimbabwe
    ].freeze

    COUNTRY_GROUP_EEA = %w[
      austria
      belgium
      bulgaria
      croatia
      cyprus
      czech-republic
      denmark
      estonia
      finland
      france
      germany
      greece
      hungary
      iceland
      ireland
      italy
      latvia
      liechtenstein
      lithuania
      luxembourg
      malta
      netherlands
      norway
      poland
      portugal
      romania
      saint-barthelemy
      slovakia
      slovenia
      spain
      st-martin
      sweden
      switzerland
    ].freeze

    COUNTRY_GROUP_ELECTRONIC_VISA_WAIVER = %w[
      bahrain
      kuwait
      oman
      qatar
      saudi-arabia
      united-arab-emirates
    ].freeze

    COUNTRY_GROUP_EPASSPORT_GATES = %w[
      australia
      austria
      belgium
      bulgaria
      canada
      croatia
      cyprus
      czech-republic
      denmark
      estonia
      finland
      france
      germany
      greece
      hungary
      iceland
      ireland
      italy
      japan
      latvia
      liechtenstein
      lithuania
      luxembourg
      malta
      netherlands
      new-zealand
      norway
      poland
      portugal
      romania
      singapore
      slovakia
      slovenia
      south-korea
      spain
      sweden
      switzerland
      usa
    ].freeze

    COUNTRY_GROUP_BRITISH_NATIONAL_OVERSEAS = %w[
      british-national-overseas
      hong-kong-(british-national-overseas)
    ].freeze

    COUNTRY_GROUP_YOUTH_MOBILITY_SCHEME = [
      COUNTRY_GROUP_BRITISH_OVERSEAS_TERRITORIES,
      COUNTRY_GROUP_BRITISH_NATIONAL_OVERSEAS,
      "australia",
      "canada",
      "hong-kong",
      "iceland",
      "japan",
      "monaco",
      "new-zealand",
      "san-marino",
      "south-korea",
      "taiwan",
    ].flatten.freeze

    COUNTRY_GROUP_UK_ANCESTRY_VISA = [
      COUNTRY_GROUP_COMMONWEALTH,
      COUNTRY_GROUP_BRITISH_OVERSEAS_TERRITORIES,
      COUNTRY_GROUP_BRITISH_NATIONAL_OVERSEAS,
      "british-overseas-citizen",
      "zimbabwe",
    ].flatten.freeze
  end
end
