module SmartAnswer::Calculators
  class RatesQuery
    def initialize(rates_filename)
      @rates_filename = rates_filename
    end

    def rates(relevant_date = Date.today)
      return @rates if @rates
      rates = data.find do |rates_hash|
        rates_hash[:start_date] <= relevant_date && rates_hash[:end_date] >= relevant_date
      end
      rates ||= data.last

      @rates = OpenStruct.new(rates)
    end

  private

    def load_path
      @load_path ||= File.join('lib', 'data', 'rates')
    end

    def data
      @data ||= YAML.load_file(Rails.root.join(load_path, "#{@rates_filename}.yml")).map(&:with_indifferent_access)
    end
  end
end
