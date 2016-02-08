module SmartAnswer::Calculators
  class MarriageAbroadCalculator
    attr_accessor :ceremony_country
    attr_accessor :resident_of
    attr_writer :partner_nationality

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

    def partner_is_not_british_nor_a_national_of_ceremony_country?
      @partner_nationality == 'partner_other'
    end

    def resident_of_uk?
      resident_of == 'uk'
    end
  end
end
