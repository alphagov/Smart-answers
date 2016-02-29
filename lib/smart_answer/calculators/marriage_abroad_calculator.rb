module SmartAnswer::Calculators
  class MarriageAbroadCalculator
    attr_accessor :ceremony_country
    attr_writer :resident_of
    attr_writer :partner_nationality
    attr_writer :sex_of_your_partner
    attr_writer :marriage_or_pacs

    def initialize(data_query: nil, country_name_formatter: nil, registrations_data_query: nil)
      @data_query = data_query || MarriageAbroadDataQuery.new
      @country_name_formatter = country_name_formatter || CountryNameFormatter.new
      @registrations_data_query = registrations_data_query || RegistrationsDataQuery.new
    end

    def partner_british?
      @partner_nationality == 'partner_british'
    end

    def partner_not_british?
      !partner_british?
    end

    def partner_is_national_of_ceremony_country?
      @partner_nationality == 'partner_local'
    end

    def partner_is_not_national_of_ceremony_country?
      !partner_is_national_of_ceremony_country?
    end

    def partner_is_neither_british_nor_a_national_of_ceremony_country?
      @partner_nationality == 'partner_other'
    end

    def resident_of_uk?
      @resident_of == 'uk'
    end

    def resident_outside_of_uk?
      !resident_of_uk?
    end

    def resident_of_ceremony_country?
      @resident_of == 'ceremony_country'
    end

    def resident_outside_of_ceremony_country?
      !resident_of_ceremony_country?
    end

    def resident_of_third_country?
      @resident_of == 'third_country'
    end

    def resident_outside_of_third_country?
      !resident_of_third_country?
    end

    def partner_is_opposite_sex?
      @sex_of_your_partner == 'opposite_sex'
    end

    def partner_is_same_sex?
      @sex_of_your_partner == 'same_sex'
    end

    def want_to_get_married?
      @marriage_or_pacs == 'marriage'
    end

    def world_location
      WorldLocation.find(ceremony_country) || raise(SmartAnswer::InvalidResponse)
    end

    def ceremony_country_name
      world_location.name
    end

    def fco_organisation
      world_location.fco_organisation
    end

    def overseas_passports_embassies
      if fco_organisation
        fco_organisation.offices_with_service 'Registrations of Marriage and Civil Partnerships'
      else
        []
      end
    end

    def marriage_and_partnership_phrases
      if @data_query.ss_marriage_countries?(ceremony_country) || @data_query.ss_marriage_countries_when_couple_british?(ceremony_country)
        'ss_marriage'
      elsif @data_query.ss_marriage_and_partnership?(ceremony_country)
        'ss_marriage_and_partnership'
      end
    end

    def country_name_lowercase_prefix
      if @country_name_formatter.requires_definite_article?(ceremony_country)
        @country_name_formatter.definitive_article(ceremony_country)
      elsif @country_name_formatter.has_friendly_name?(ceremony_country)
        @country_name_formatter.friendly_name(ceremony_country).html_safe
      else
        ceremony_country_name
      end
    end

    def country_name_uppercase_prefix
      @country_name_formatter.definitive_article(ceremony_country, true)
    end

    def country_name_partner_residence
      if @data_query.british_overseas_territories?(ceremony_country)
        'British (overseas territories citizen)'
      elsif ceremony_country_is_french_overseas_territory?
        'French'
      elsif @data_query.dutch_caribbean_islands?(ceremony_country)
        'Dutch'
      elsif %w(hong-kong macao).include?(ceremony_country)
        'Chinese'
      else
        "National of #{country_name_lowercase_prefix}"
      end
    end

    def embassy_or_consulate_ceremony_country
      if @registrations_data_query.has_consulate?(ceremony_country) || @registrations_data_query.has_consulate_general?(ceremony_country)
        'consulate'
      else
        'embassy'
      end
    end

    def ceremony_country_is_french_overseas_territory?
      @data_query.french_overseas_territories?(ceremony_country)
    end
  end
end
