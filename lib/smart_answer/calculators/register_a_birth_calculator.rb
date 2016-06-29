module SmartAnswer::Calculators
  class RegisterABirthCalculator
    include ActiveModel::Model

    attr_accessor :country_of_birth

    def initialize
      @reg_data_query = RegistrationsDataQuery.new
      @country_name_query = CountryNameFormatter.new
    end

    def registration_country
      @reg_data_query.registration_country_slug(country_of_birth)
    end

    def registration_country_name_lowercase_prefix
      @country_name_query.definitive_article(registration_country)
    end
  end
end
