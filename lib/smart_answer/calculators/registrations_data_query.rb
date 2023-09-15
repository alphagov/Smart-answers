module SmartAnswer::Calculators
  class RegistrationsDataQuery
    COMMONWEALTH_COUNTRIES = %w[
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

    COUNTRIES_WITHOUT_UK_REGISTRATION = %w[
      anguilla
      australia
      bermuda
      british-indian-ocean-territory
      british-virgin-islands
      canada
      cayman-islands
      falkland-islands
      gibraltar
      ireland
      montserrat
      new-zealand
      pitcairn
      south-georgia-and-the-south-sandwich-islands
      st-helena-ascension-and-tristan-da-cunha
      turks-and-caicos-islands
    ].freeze

    EEA_COUNTRIES = %w[
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
      slovakia
      slovenia
      spain
      sweden
    ].freeze

    COUNTRIES_WITH_CONSULATES = %w[
      china
      colombia
      israel
      russia
      turkey
    ].freeze

    COUNTRIES_WITH_CONSULATE_GENERALS = %w[
      brazil
      hong-kong
      turkey
    ].freeze

    COUNTRIES_WITH_BIRTH_REGISTRATION_EXCEPTION = %w[
      afghanistan
      iran
      iraq
      jordan
      kuwait
      oman
      pakistan
      qatar
      saudi-arabia
      united-arab-emirates
    ].freeze

    ORU_DOCUMENTS_VARIANT_COUNTRIES_BIRTH = %w[
      andorra
      belgium
      denmark
      finland
      france
      india
      israel
      italy
      japan
      monaco
      morocco
      nepal
      netherlands
      nigeria
      poland
      portugal
      russia
      sierra-leone
      south-korea
      spain
      sri-lanka
      sweden
      taiwan
      the-occupied-palestinian-territories
      turkey
      united-arab-emirates
      usa
    ].freeze

    ORU_DOCUMENTS_VARIANT_COUNTRIES_DEATH = %w[
      papua-new-guinea
      poland
    ].freeze

    ORU_COURIER_VARIANTS = %w[
      cambodia
      cameroon
      kenya
      nigeria
      north-korea
      papua-new-guinea
      uganda
    ].freeze

    ORU_COURIER_BY_HIGH_COMISSION = %w[
      cameroon
      kenya
      nigeria
    ].freeze

    HIGHER_RISK_COUNTRIES = %w[
      afghanistan
      algeria
      azerbaijan
      bangladesh
      bhutan
      colombia
      india
      iraq
      kenya
      lebanon
      libya
      nepal
      new-caledonia
      nigeria
      pakistan
      philippines
      russia
      sierra-leone
      somalia
      south-sudan
      sri-lanka
      sudan
      uganda
    ].freeze

    ORU_REGISTRATION_DURATION = {
      "afghanistan" => "6 months",
      "algeria" => "12 weeks",
      "azerbaijan" => "10 weeks",
      "bangladesh" => "8 months",
      "bhutan" => "8 weeks",
      "colombia" => "8 weeks",
      "india" => "16 weeks",
      "iraq" => "12 weeks",
      "kenya" => "12 weeks",
      "lebanon" => "12 weeks",
      "libya" => "6 months",
      "nepal" => "10 weeks",
      "nigeria" => "14 weeks",
      "pakistan" => "6 months",
      "russia" => "10 weeks",
      "sierra-leone" => "12 weeks",
      "somalia" => "12 weeks",
      "south-sudan" => "12 weeks",
      "sri-lanka" => "12 weeks",
      "sudan" => "12 weeks",
      "philippines" => "16 weeks",
      "uganda" => "12 weeks",
    }.freeze

    attr_reader :data

    def initialize
      @data = self.class.registration_data
    end

    def commonwealth_country?(country_slug)
      COMMONWEALTH_COUNTRIES.include?(country_slug)
    end

    def nonregistrable_country?(country_slug)
      COUNTRIES_WITHOUT_UK_REGISTRATION.include?(country_slug)
    end

    def eea_country?(country_slug)
      EEA_COUNTRIES.include?(country_slug)
    end

    def eea_country_or_switzerland?(country_slug)
      eea_country?(country_slug) || country_slug == "switzerland"
    end

    def has_consulate?(country_slug)
      COUNTRIES_WITH_CONSULATES.include?(country_slug)
    end

    def has_consulate_general?(country_slug)
      COUNTRIES_WITH_CONSULATE_GENERALS.include?(country_slug)
    end

    def registration_country_slug(country_slug)
      data["registration_country"][country_slug] || country_slug
    end

    def oru_documents_variant_for_death?(country_slug)
      ORU_DOCUMENTS_VARIANT_COUNTRIES_DEATH.include?(country_slug)
    end

    def oru_courier_variant?(country_slug)
      ORU_COURIER_VARIANTS.include?(country_slug)
    end

    def oru_courier_by_high_commission?(country_slug)
      ORU_COURIER_BY_HIGH_COMISSION.include?(country_slug)
    end

    def document_return_fees
      RatesQuery.from_file("births_and_deaths_document_return_fees").rates
    end

    def register_a_death_fees
      RatesQuery.from_file("register_a_death").rates
    end

    def self.registration_data
      @registration_data ||= YAML.load_file(Rails.root.join("config/smart_answers/registrations.yml"))
    end
  end
end
