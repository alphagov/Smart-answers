module SmartAnswer::Calculators
  class OverseasPassportsCalculator
    APPLY_IN_NEIGHBOURING_COUNTRIES = %w(
      british-indian-ocean-territory north-korea south-georgia-and-south-sandwich-islands
    )

    BOOK_APPOINTMENT_ONLINE_COUNTRIES = %w(
      kyrgyzstan tajikistan turkmenistan uzbekistan
    )

    EXCLUDE_COUNTRIES = %w(
      holy-see british-antarctic-territory
    )

    INELIGIBLE_COUNTRIES = %w(
      iran libya syria yemen
    )

    IPS_APPLICATION_TYPES = %w(
      ips_application_1
      ips_application_2
      ips_application_3
    )

    UK_VISA_APPLICATION_CENTRE_COUNTRIES = %w(
      afghanistan algeria azerbaijan bangladesh belarus burundi burma cambodia
      china gaza georgia india indonesia kazakhstan kyrgyzstan laos lebanon
      mauritania morocco nepal pakistan russia tajikistan thailand turkmenistan
      ukraine uzbekistan western-sahara vietnam venezuela
    )

    UK_VISA_APPLICATION_WITH_COLOUR_PICTURES_COUNTRIES = %w(
      afghanistan azerbaijan algeria bangladesh belarus burma cambodia china
      georgia india indonesia kazakhstan laos lebanon mauritania morocco nepal
      pakistan tajikistan thailand turkmenistan ukraine uzbekistan russia
      vietnam venezuela western-sahara
    )

    NON_UK_VISA_APPLICATION_WITH_COLOUR_PICTURES_COUNTRIES = %w(
      burma cuba sudan tajikistan turkmenistan uzbekistan
    )

    attr_accessor :current_location
    attr_accessor :birth_location
    attr_accessor :application_action
    attr_accessor :child_or_adult

    def initialize(data_query: nil)
      @data_query = data_query || PassportAndEmbassyDataQuery.new
    end

    def book_appointment_online?
      BOOK_APPOINTMENT_ONLINE_COUNTRIES.include?(current_location)
    end

    def uk_visa_application_centre?
      UK_VISA_APPLICATION_CENTRE_COUNTRIES.include?(current_location)
    end

    def uk_visa_application_with_colour_pictures?
      UK_VISA_APPLICATION_WITH_COLOUR_PICTURES_COUNTRIES.include?(current_location)
    end

    def non_uk_visa_application_with_colour_pictures?
      NON_UK_VISA_APPLICATION_WITH_COLOUR_PICTURES_COUNTRIES.include?(current_location)
    end

    def ineligible_country?
      INELIGIBLE_COUNTRIES.include?(current_location)
    end

    def apply_in_neighbouring_countries?
      APPLY_IN_NEIGHBOURING_COUNTRIES.include?(current_location)
    end

    def alternate_embassy_location
      PassportAndEmbassyDataQuery::ALT_EMBASSIES[current_location]
    end

    def world_location
      search_location = alternate_embassy_location || current_location

      WorldLocation.find(search_location)
    end

    def world_location_name
      world_location.name
    end

    def fco_organisation
      world_location.fco_organisation
    end

    def cash_only_country?
      @data_query.cash_only_countries?(current_location)
    end

    def renewing_country?
      @data_query.renewing_countries?(current_location)
    end

    def renewing_new?
      application_action == 'renewing_new'
    end

    def renewing_old?
      application_action == 'renewing_old'
    end

    def applying?
      application_action == 'applying'
    end

    def replacing?
      application_action == 'replacing'
    end

    def overseas_passports_embassies
      organisation = fco_organisation
      organisation ? organisation.offices_with_service('Overseas Passports Service') : []
    end

    def general_action
      application_action =~ /^renewing_/ ? 'renewing' : application_action
    end

    def passport_data(location = current_location)
      @data_query.find_passport_data(location)
    end

    def application_type
      data = passport_data
      data ? data['type'] : nil
    end

    def application_form
      data = passport_data
      data ? data['app_form'] : nil
    end

    def application_group(location)
      data = passport_data(location)
      data ? data['group'] : nil
    end

    def supporting_documents
      if birth_location.blank? || birth_location == 'united_kingdom'
        application_group(current_location)
      else
        application_group(birth_location)
      end
    end

    def ips_application?
      IPS_APPLICATION_TYPES.include?(application_type)
    end

    def ips_number
      application_type.split("_")[2] if ips_application?
    end

    def ips_docs_number
      supporting_documents.split("_")[3] if ips_application?
    end
  end
end
