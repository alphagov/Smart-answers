module SmartAnswer::Calculators
  class PassportAndEmbassyDataQuery
    def ineligible_country?
      SmartAnswer::Predicate::RespondedWith.new(%w{iran syria})
    end

    def apply_in_neighbouring_countries?
      SmartAnswer::Predicate::RespondedWith.new(
        %w(british-indian-ocean-territory north-korea south-georgia-and-south-sandwich-islands)
      )
    end

    def ips_application?
      SmartAnswer::Predicate::VariableMatches.new(:application_type,
        %w{ips_application_1 ips_application_2 ips_application_3},
        "IPS")
    end

    def fco_application?
      SmartAnswer::Predicate::VariableMatches.new(:application_type, %w{pretoria_south_africa})
    end

    include ActionView::Helpers::NumberHelper

    ALT_EMBASSIES = {
      'benin' =>  'nigeria',
      'guinea' => 'ghana'
    }

    RETAIN_PASSPORT_COUNTRIES = %w(angola brazil burundi cuba
    egypt eritrea georgia iraq lebanon libya morocco rwanda sri-lanka sudan timor-leste tunisia uganda yemen zambia)

    RETAIN_PASSPORT_COUNTRIES_HURRICANES = %w(anguilla antigua-and-barbuda bahamas bermuda bonaire-st-eustatius-saba british-virgin-islands cayman-islands curacao dominica dominican-republic french-guiana grenada guadeloupe guyana haiti martinique mexico montserrat st-maarten st-kitts-and-nevis st-lucia st-pierre-and-miquelon st-vincent-and-the-grenadines suriname trinidad-and-tobago turks-and-caicos-islands)

    PASSPORT_COSTS = {
      'Australian Dollars'  => [[282.21], [325.81], [205.81]],
      'Euros'               => [[161, 186],   [195, 220],   [103, 128]],
      'New Zealand Dollars' => [["317.80", 337.69], ["371.80", 391.69], ["222.80", 242.69]],
      'SLL'                 => [[900000, 1135000], [1085000, 1320000], [575000, 810000]],
      'South African Rand'  => [[2112, 2440], [2549, 2877], [1345, 1673]]
    }

    CASH_ONLY_COUNTRIES = %w(cuba sudan)

    RENEWING_COUNTRIES = %w(belarus burma cuba lebanon libya russia sudan tajikistan tunisia turkmenistan uzbekistan zimbabwe)

    attr_reader :passport_data

    def initialize
      @passport_data = self.class.passport_data
    end

    def find_passport_data(country_slug)
      passport_data[country_slug]
    end

    def retain_passport?(country_slug)
      RETAIN_PASSPORT_COUNTRIES.include?(country_slug)
    end

    def retain_passport_hurricanes?(country_slug)
      RETAIN_PASSPORT_COUNTRIES_HURRICANES.include?(country_slug)
    end

    def cash_only_countries?(country_slug)
      CASH_ONLY_COUNTRIES.include?(country_slug)
    end

    def renewing_countries?(country_slug)
      RENEWING_COUNTRIES.include?(country_slug)
    end

    def passport_costs
      {}.tap do |costs|
        PASSPORT_COSTS.each do |k, v|
          [:adult_32, :adult_48, :child].each_with_index do |t, i|
            key = "#{k.downcase.gsub(' ', '_')}_#{t}"
            costs[key] = v[i].map { |c| "#{number_with_delimiter(c)} #{k}"}.join(" | ")
          end
        end
      end
    end

    def self.passport_data
      @passport_data ||= YAML.load_file(Rails.root.join("lib", "data", "passport_data_v2.yml"))
    end
  end
end
