status :published
satisfies_need "101000"

data_query = SmartAnswer::Calculators::MarriageAbroadDataQuery.new
reg_data_query = SmartAnswer::Calculators::RegistrationsDataQuery.new
exclude_countries = %w(holy-see british-antarctic-territory the-occupied-palestinian-territories)

# Q1
country_select :country_of_ceremony?, exclude_countries: exclude_countries do
  save_input_as :ceremony_country

  calculate :location do
    loc = WorldLocation.find(ceremony_country)
    raise InvalidResponse unless loc
    loc
  end
  calculate :organisation do
    location.fco_organisation
  end
  calculate :overseas_passports_embassies do
    if organisation
      organisation.offices_with_service 'Registrations of Marriage and Civil Partnerships'
    else
      []
    end
  end

  calculate :marriage_and_partnership_phrases do
    if data_query.ss_marriage_countries?(ceremony_country) | data_query.ss_marriage_countries_when_couple_british?(ceremony_country)
      "ss_marriage"
    elsif data_query.ss_marriage_and_partnership?(ceremony_country)
      "ss_marriage_and_partnership"
    end
  end

  calculate :ceremony_country_name do
    location.name
  end
  calculate :country_name_lowercase_prefix do
    if data_query.countries_with_definitive_articles?(ceremony_country)
      "the #{ceremony_country_name}"
    elsif SmartAnswer::Calculators::MarriageAbroadDataQuery::COUNTRY_NAME_TRANSFORM.has_key?(ceremony_country)
      SmartAnswer::Calculators::MarriageAbroadDataQuery::COUNTRY_NAME_TRANSFORM[ceremony_country]
    else
      ceremony_country_name
    end
  end
  calculate :country_name_uppercase_prefix do
    if data_query.countries_with_definitive_articles?(ceremony_country)
      "The #{ceremony_country_name}"
    else
      country_name_lowercase_prefix
    end
  end

  calculate :country_name_partner_residence do
    if data_query.british_overseas_territories?(ceremony_country)
      "British (overseas territories citizen)"
    elsif data_query.french_overseas_territories?(ceremony_country)
      "French"
    elsif data_query.dutch_caribbean_islands?(ceremony_country)
      "Dutch"
    elsif %w(hong-kong macao).include?(ceremony_country)
      "Chinese"
    else
      "National of #{country_name_lowercase_prefix}"
    end
  end
  calculate :clickbook_data do
    reg_data_query.clickbook(ceremony_country)
  end
  calculate :multiple_clickbooks do
    clickbook_data and clickbook_data.class == Hash
  end
  calculate :embassy_or_consulate_ceremony_country do
    if reg_data_query.has_consulate?(ceremony_country) or reg_data_query.has_consulate_general?(ceremony_country)
      "consulate"
    else
      "embassy"
    end
  end

  next_node_if(:partner_opposite_or_same_sex?, responded_with('ireland'))
  next_node_if(:marriage_or_pacs?, responded_with(%w(france monaco new-caledonia wallis-and-futuna)))
  next_node_if(:outcome_os_france_or_fot, ->(response) { data_query.french_overseas_territories?(response)})
  next_node(:legal_residency?)
end

# Q2
multiple_choice :legal_residency? do
  option :uk
  option :other

  save_input_as :resident_of

  on_condition(responded_with('uk')) do
    next_node_if(:partner_opposite_or_same_sex?, variable_matches(:ceremony_country, 'switzerland'))
    next_node(:residency_uk?)
  end
  next_node(:residency_nonuk?)
end

# Q3a
multiple_choice :residency_uk? do
  option :uk_england
  option :uk_wales
  option :uk_scotland
  option :uk_ni
  option :uk_iom
  option :uk_ci

  save_input_as :residency_uk_region

  on_condition(responded_with(%w{uk_iom uk_ci})) do
    next_node_if(:what_is_your_partners_nationality?,
      ->(_) {
        data_query.os_other_countries?(ceremony_country) ||
        data_query.ss_marriage_countries?(ceremony_country) ||
        data_query.ss_marriage_and_partnership?(ceremony_country) ||
        %w(portugal).include?(ceremony_country)
      })
    next_node_if(:outcome_os_iom_ci)
  end
  next_node(:what_is_your_partners_nationality?)
end

# Q3b
country_select :residency_nonuk?, exclude_countries: exclude_countries do
  save_input_as :residency_country
  countries_that_show_their_embassies_data = %w(belarus brazil dominican-republic egypt el-salvador ethiopia finland honduras hungary indonesia south-korea latvia lebanon mongolia nepal oman panama peru philippines qatar slovakia thailand united-arab-emirates vietnam portugal)
  calculate :location do
    if countries_that_show_their_embassies_data.include?(ceremony_country) and %w(other).include?(resident_of)
      loc = WorldLocation.find(ceremony_country)
    else
      loc = WorldLocation.find(residency_country)
    end
    raise InvalidResponse unless loc
    loc
  end
  calculate :organisation do
    location.fco_organisation
  end
  calculate :overseas_passports_embassies do
    if organisation
      organisation.offices_with_service 'Registrations of Marriage and Civil Partnerships'
    else
      []
    end
  end


  calculate :residency_country_name do
    location.name
  end
  calculate :residency_country_name_lowercase_prefix do
    if data_query.countries_with_definitive_articles?(residency_country)
      "the #{residency_country_name}"
    elsif SmartAnswer::Calculators::MarriageAbroadDataQuery::COUNTRY_NAME_TRANSFORM.has_key?(residency_country)
      SmartAnswer::Calculators::MarriageAbroadDataQuery::COUNTRY_NAME_TRANSFORM[residency_country]
    else
      residency_country_name
    end
  end

  calculate :embassy_or_consulate_residency_country do
    if reg_data_query.has_consulate?(residency_country) or reg_data_query.has_consulate_general?(residency_country)
      "consulate"
    else
      "embassy"
    end
  end

  next_node_if(:partner_opposite_or_same_sex?, variable_matches(:ceremony_country, "switzerland"))
  next_node(:what_is_your_partners_nationality?)
end

# Q3c
multiple_choice :marriage_or_pacs? do
  option :marriage
  option :pacs

  next_node_if(:outcome_os_france_or_fot, responded_with('marriage'))
  next_node(:outcome_cp_france_pacs)
end

# Q4
multiple_choice :what_is_your_partners_nationality? do
  option :partner_british
  option :partner_irish
  option :partner_local
  option :partner_other

  save_input_as :partner_nationality
  next_node :partner_opposite_or_same_sex?
end

# Q5
multiple_choice :partner_opposite_or_same_sex? do
  option :opposite_sex
  option :same_sex

  save_input_as :sex_of_your_partner

  calculate :ceremony_type do
    if responses.last == 'opposite_sex'
      PhraseList.new(:ceremony_type_marriage)
    else
      PhraseList.new(:ceremony_type_civil_partnership)
    end
  end

  calculate :ceremony_type_lowercase do
    if responses.last == 'opposite_sex'
      "marriage"
    else
      "civil partnership"
    end
  end

  next_node_if(:outcome_netherlands, variable_matches(:ceremony_country, "netherlands"))
  next_node_if(:outcome_portugal, variable_matches(:ceremony_country, "portugal"))
  next_node_if(:outcome_ireland, variable_matches(:ceremony_country, "ireland"))
  next_node_if(:outcome_switzerland, variable_matches(:ceremony_country, "switzerland"))
  on_condition(responded_with('opposite_sex')) do
    next_node_if(:outcome_os_indonesia, variable_matches(:ceremony_country, "indonesia"))
    next_node_if(:outcome_os_affirmation, ->(_) { data_query.os_affirmation_countries?(ceremony_country) })
    next_node_if(:outcome_os_commonwealth, ->(_) { data_query.commonwealth_country?(ceremony_country) or %w(zimbabwe).include?(ceremony_country) })
    next_node_if(:outcome_os_bot, ->(_) { data_query.british_overseas_territories?(ceremony_country) })
    next_node_if(:outcome_os_consular_cni, ->(_) {
      data_query.os_consular_cni_countries?(ceremony_country) or (%w(uk).include?(resident_of) and data_query.os_no_marriage_related_consular_services?(ceremony_country))
     })
    next_node_if(:outcome_os_no_cni, ->(_) {
      data_query.os_no_consular_cni_countries?(ceremony_country) or (%w(other).include?(resident_of) and data_query.os_no_marriage_related_consular_services?(ceremony_country))
    })
    next_node_if(:outcome_os_other_countries, ->(_) {
      data_query.os_other_countries?(ceremony_country)
    })
  end

  define_predicate(:ss_marriage_countries?) {
    data_query.ss_marriage_countries?(ceremony_country)
  }
  define_predicate(:ss_marriage_countries_when_couple_british?) {
    data_query.ss_marriage_countries_when_couple_british?(ceremony_country) & %w(partner_british).include?(partner_nationality)
  }
  define_predicate(:ss_marriage_and_partnership?) {
    data_query.ss_marriage_and_partnership?(ceremony_country)
  }

  define_predicate(:ss_marriage_not_possible?) {
    data_query.ss_marriage_not_possible?(ceremony_country, partner_nationality)
  }

  next_node_if(:outcome_ss_marriage_not_possible, ss_marriage_not_possible?)

  next_node_if(:outcome_ss_marriage,
    ss_marriage_countries? | ss_marriage_countries_when_couple_british? | ss_marriage_and_partnership?
  )

  next_node_if(:outcome_os_consular_cni, variable_matches(:ceremony_country, "spain"))

  next_node_if(:outcome_cp_cp_or_equivalent, ->(_) {
    data_query.cp_equivalent_countries?(ceremony_country)
  })
  next_node_if(:outcome_cp_no_cni, ->(_) {
    data_query.cp_cni_not_required_countries?(ceremony_country)
  })
  next_node_if(:outcome_cp_commonwealth_countries, ->(_) {
    %w(canada new-zealand south-africa).include?(ceremony_country)
  })
  next_node_if(:outcome_cp_consular, ->(_) {
    data_query.cp_consular_countries?(ceremony_country)
  })
  next_node(:outcome_cp_all_other_countries)
end

outcome :outcome_os_iom_ci do
  precalculate :iom_ci_os_outcome do
    phrases = PhraseList.new
    phrases << :iom_ci_os_all
    phrases << :iom_ci_os_spain if %w(spain).include?(ceremony_country)
    if %w(uk_iom).include?(residency_uk_region)
      phrases << :iom_ci_os_resident_of_iom
    else
      phrases << :iom_ci_os_resident_of_ci
    end
    if %w(italy).include?(ceremony_country)
      phrases << :iom_ci_os_ceremony_italy
    else
      phrases << :embassies_data
    end
    phrases
  end
end

outcome :outcome_ireland do
  precalculate :ireland_partner_sex_variant do
    if %w(opposite_sex).include?(sex_of_your_partner)
      PhraseList.new(:outcome_ireland_opposite_sex)
    else
      PhraseList.new(:outcome_ireland_same_sex)
    end
  end
end

outcome :outcome_switzerland do
  precalculate :switzerland_marriage_outcome do
    phrases = PhraseList.new
    if %w(opposite_sex).include?(sex_of_your_partner)
      phrases << :switzerland_os_variant
    else
      phrases << :switzerland_ss_variant
    end

    unless %w(switzerland).include?(residency_country)
      if %w(uk).include?(resident_of)
        phrases << :what_you_need_to_do_switzerland_resident_uk
      end
      phrases << :switzerland_not_resident
      if %w(opposite_sex).include?(sex_of_your_partner)
        phrases << :switzerland_os_not_resident
      else
        phrases << :switzerland_ss_not_resident
      end
      phrases << :switzerland_not_resident_two
    end
    phrases
  end
end

outcome :outcome_netherlands do
  precalculate :netherlands_phraselist do
    PhraseList.new(
      :contact_local_authorities,
      :get_legal_advice,
      :partner_naturalisation_in_uk
    )
  end
end

outcome :outcome_portugal do
  precalculate :portugal_phraselist do
    PhraseList.new(:contact_civil_register_office_portugal)
  end
  precalculate :portugal_title do
    phrases = PhraseList.new
    if %w(opposite_sex).include?(sex_of_your_partner)
      phrases << :marriage_title
    else
      phrases << :same_sex_marriage_title
    end
  end
end

outcome :outcome_os_indonesia do
  precalculate :indonesia_os_phraselist do
    PhraseList.new(
      :appointment_for_affidavit,
      :complete_affidavit_with_download_link,
      :embassies_data,
      :documents_for_divorced_or_widowed,
      :partner_affidavit_needed,
      :fee_table_45_70_55
    )
  end
end

outcome :outcome_os_commonwealth do
  precalculate :commonwealth_os_outcome do
    phrases = PhraseList.new

    if %w(zimbabwe).include?(ceremony_country)
      if %w(uk).include?(resident_of)
        phrases << :uk_resident_os_ceremony_zimbabwe
      elsif residency_country == ceremony_country
        phrases << :local_resident_os_ceremony_zimbabwe
      else
        phrases << :other_resident_os_ceremony_zimbabwe
      end
      phrases << :commonwealth_os_all_cni_zimbabwe
    else
      if %w(uk).include?(resident_of)
        phrases << :uk_resident_os_ceremony_not_zimbabwe
      elsif residency_country == ceremony_country
        phrases << :local_resident_os_ceremony_not_zimbabwe
      else
        phrases << :other_resident_os_ceremony_not_zimbabwe
      end
      phrases << :commonwealth_os_all_cni
    end

    case ceremony_country
    when 'south-africa'
      if %w(partner_local).include?(partner_nationality)
        phrases << :commonwealth_os_other_countries_south_africe
      end
    when 'india'
      phrases << :commonwealth_os_other_countries_india
    when 'malaysia'
      phrases << :commonwealth_os_other_countries_malaysia
    when 'singapore'
      phrases << :commonwealth_os_other_countries_singapore
    when 'brunei'
      phrases << :commonwealth_os_other_countries_brunei
    when 'cyprus'
      phrases << :commonwealth_os_other_countries_cyprus if %w(cyprus).include?(residency_country)
    end
    phrases << :commonwealth_os_naturalisation if %w(partner_british).exclude?(partner_nationality)
    phrases
  end
end

outcome :outcome_os_bot do
  precalculate :bot_outcome do
    phrases = PhraseList.new
    if %w(british-indian-ocean-territory).include?(ceremony_country)
      phrases << :bot_os_ceremony_biot
    elsif %w(british-virgin-islands).include?(ceremony_country)
      phrases << :bot_os_ceremony_bvi
    else
      phrases << :bot_os_ceremony_non_biot
      phrases << :bot_os_not_local_resident if residency_country != ceremony_country
      phrases << :bot_os_naturalisation if not %w(partner_british).include?(partner_nationality)
    end
    phrases
  end
end

outcome :outcome_os_consular_cni do
  precalculate :consular_cni_os_start do
    phrases = PhraseList.new

    cni_posted_after_7_days_countries = %w(albania algeria angola austria azerbaijan bahrain bolivia bosnia-herzegovina cambodia chile croatia cuba ecuador estonia georgia greece hong-kong iceland iran italy japan kazakhstan kuwait kyrgyzstan libya lithuania luxembourg macedonia montenegro nicaragua norway poland russia spain sweden tajikistan tunisia turkmenistan ukraine uzbekistan venezuela)
    cni_posted_after_14_days_countries = %w(oman jordan qatar saudi-arabia united-arab-emirates yemen)
    not_italy_or_spain = %w(italy spain).exclude?(ceremony_country)
    ceremony_not_germany_or_not_resident_other = (%w(germany).exclude?(ceremony_country) or %w(other).exclude?(resident_of))
    ceremony_and_residency_in_croatia = %w(croatia).include?(ceremony_country) and %w(croatia).include?(residency_country)

    if %w(ecuador).include?(ceremony_country) and %w(partner_local).include?(partner_nationality) and %w(ecuador).exclude?(residency_country)
      phrases << :ecuador_os_consular_cni
    end
    if %w(uk).include?(resident_of) and %w(italy).exclude?(ceremony_country) and not data_query.dutch_caribbean_islands?(ceremony_country)
      phrases << :uk_resident_os_consular_cni
    elsif residency_country == ceremony_country and %w(italy).exclude?(ceremony_country)
      phrases << :local_resident_os_consular_cni
    elsif %w(uk).include?(resident_of) and data_query.dutch_caribbean_islands?(ceremony_country)
      phrases << :uk_resident_os_consular_cni_dutch_caribbean_islands
    else
      unless %w(uk).include?(resident_of) or ceremony_country == residency_country or %w(italy).include?(ceremony_country)
        phrases << :other_resident_os_consular_cni
      end
    end
    if %w(jordan oman qatar).include?(ceremony_country)
      phrases << :gulf_states_os_consular_cni
      if residency_country == ceremony_country and %w(partner_irish).exclude?(partner_nationality)
        phrases << :gulf_states_os_consular_cni_local_resident_partner_not_irish
      end
    end
    if %w(spain).include?(ceremony_country)
      if %w(opposite_sex).include?(sex_of_your_partner)
        phrases << :spain_os_consular_cni_opposite_sex
      else
        phrases << :spain_os_consular_cni_same_sex
      end
      phrases << :spain_os_consular_civil_registry
      phrases << :spain_os_consular_cni_not_local_resident if %w(spain).exclude?(residency_country)
    elsif %w(italy).include?(ceremony_country)
      phrases << :italy_os_consular_cni_ceremony_italy
    else
      phrases << :italy_os_consular_cni_ceremony_not_italy_or_spain
    end
    phrases << :consular_cni_all_what_you_need_to_do

    if ceremony_and_residency_in_croatia
      phrases << :what_to_do_croatia
    elsif not_italy_or_spain && ceremony_not_germany_or_not_resident_other
      phrases << :consular_cni_os_ceremony_not_spain_or_italy
    end

    if %w(spain).include?(ceremony_country)
      phrases << :spain_os_consular_cni_two
    elsif %w(italy).include?(ceremony_country)
      if %w(uk).include?(resident_of)
        if %w(partner_irish).exclude?(partner_nationality) or (%w(uk_scotland uk_ni).include?(residency_uk_region) and %w(partner_irish).include?(partner_nationality))
          phrases << :italy_os_consular_cni_uk_resident
        end
      end
      if %w(uk).include?(resident_of) and %w(partner_british).include?(partner_nationality)
        phrases << :italy_os_consular_cni_uk_resident_two
      end
      if %w(uk).exclude?(resident_of) or (%w(uk).include?(resident_of) and %w(partner_irish).include?(partner_nationality) and %w(uk_scotland uk_ni).exclude?(residency_uk_region))
        phrases << :italy_os_consular_cni_uk_resident_three
      end
    end

    if %w(denmark).include?(ceremony_country)
      phrases << :consular_cni_os_denmark
    elsif %w(germany).include?(ceremony_country)
      if %w(germany).include?(residency_country)
        phrases << :consular_cni_os_german_resident
      else
        phrases << :consular_cni_os_not_germany_or_uk_resident if %w(other).include?(resident_of)
      end
      phrases << :consular_cni_os_ceremony_germany_not_uk_resident if %w(other).include?(resident_of)
    elsif %w(china).include?(ceremony_country)
      if %w(china).include?(residency_country)
        phrases << :consular_cni_os_china_local_resident
      else
        phrases << :consular_cni_os_china_not_local_resident
      end
      if %w(partner_local).exclude?(partner_nationality)
        phrases << :consular_cni_os_china_not_local_partner
      end
    end
    if %w(uk).include?(resident_of)
      if cni_posted_after_14_days_countries.include?(ceremony_country)
        phrases << :cni_posted_if_no_objection_14_days
      elsif cni_posted_after_7_days_countries.include?(ceremony_country)
        phrases << :cni_posted_if_no_objection_7_days
      elsif %w(partner_irish).exclude?(partner_nationality)
        phrases << :uk_resident_partner_not_irish_os_consular_cni_three
      elsif %w(partner_irish).include?(partner_nationality) and %w(uk_scotland uk_ni).include?(residency_uk_region)
        phrases << :scotland_ni_resident_partner_irish_os_consular_cni_three
      end
      if %w(italy).include?(ceremony_country)
        if %w(uk_england uk_wales).include?(residency_uk_region)
          if %w(partner_irish).include?(partner_nationality)
            phrases << :consular_cni_os_england_or_wales_partner_irish_three
          else
            phrases << :consular_cni_os_scotland_or_ni_partner_irish_or_partner_not_irish_three
          end
        else
          phrases << :consular_cni_os_scotland_or_ni_partner_irish_or_partner_not_irish_three
        end
      end
    end
    if %w(italy).exclude?(ceremony_country) and %w(partner_irish).include?(partner_nationality)
      if %w(uk_england uk_wales).include?(residency_uk_region)
        phrases << :consular_cni_os_england_or_wales_resident_not_italy
      end
    end

    if %w(uk).include?(resident_of)
      if %w(china italy kazakhstan kyrgyzstan montenegro poland portugal).exclude?(ceremony_country)
        phrases << :consular_cni_os_uk_resident_legalisation
      elsif %w(montenegro).include?(ceremony_country)
        phrases << :consular_cni_os_uk_resident_montenegro
      elsif %w(kazakhstan kyrgyzstan poland).include?(ceremony_country)
        phrases << :consular_cni_os_uk_resident_poland_kazak_kyrg
      end
      phrases << :consular_cni_os_uk_resident_not_italy_or_portugal if %w(china italy portugal).exclude?(ceremony_country)
      if %w(portugal).include?(ceremony_country)
        phrases << :consular_cni_os_uk_resident_ceremony_portugal
        if reg_data_query.clickbook(ceremony_country)
          multiple_clickbooks ? phrases << :clickbook_links : phrases << :clickbook_link
        end
      elsif %w(china).include?(ceremony_country)
        phrases << :consular_cni_os_uk_resident_ceremony_china
        phrases << :consular_cni_os_uk_resident_ceremony_china_local_partner if %w(partner_local).include?(partner_nationality)
      end
    end

    if ceremony_country == residency_country
      if %w(croatia).include?(ceremony_country)
        phrases << :consular_cni_os_local_resident_table
      elsif %w(germany italy kazakhstan russia).exclude?(ceremony_country)
        phrases << :consular_cni_os_local_resident_not_italy_germany
      end
      phrases << :"#{ceremony_country}_os_local_resident" if %w(kazakhstan russia).include?(ceremony_country)
      if not %w(germany italy japan russia spain).include?(ceremony_country)
        if reg_data_query.clickbook(ceremony_country)
          if %w(vietnam).include?(ceremony_country)
            phrases << :consular_cni_os_vietnam_clickbook
          else
            multiple_clickbooks ? phrases << :clickbook_links : phrases << :clickbook_link
          end
        end
        if %w(croatia).include?(ceremony_country)
          phrases << :make_appointment_online_croatia
        elsif not reg_data_query.clickbook(ceremony_country)
          phrases << :embassies_data
        end
      end
      phrases << :consular_cni_os_local_resident_italy if %w(italy).include?(ceremony_country)
    end

    if data_query.non_commonwealth_country?(residency_country) and %w(ireland).exclude?(residency_country) and ceremony_country != residency_country
      if %w(germany italy).exclude?(ceremony_country)
        phrases << :consular_cni_os_foreign_resident_ceremony_not_germany_italy
      elsif %w(italy).include?(ceremony_country)
        phrases << :consular_cni_os_foreign_resident_ceremony_country_italy
      end
      if not %w(germany).include?(ceremony_country)
        if cni_posted_after_7_days_countries.include?(ceremony_country)
          phrases << :consular_cni_os_foreign_resident_3_days
        else
          phrases << :consular_cni_os_foreign_resident_ceremony_country_not_germany
        end
      end
    end

    if data_query.commonwealth_country?(residency_country) and %w(ireland).exclude?(residency_country) and %w(germany).exclude?(ceremony_country) and ceremony_country != residency_country
      phrases << :consular_cni_os_commonwealth_resident
    end

    if data_query.commonwealth_country?(residency_country) and %w(partner_british).include?(partner_nationality) and ceremony_country != residency_country and %w(germany).exclude?(ceremony_country)
      phrases << :consular_cni_os_commonwealth_resident_british_partner
    end
    if data_query.commonwealth_country?(residency_country) and ceremony_country != residency_country and %w(germany).exclude?(ceremony_country)
      phrases << :consular_cni_os_commonwealth_resident_two
    elsif %w(ireland).include?(residency_country) and %w(germany).exclude?(ceremony_country)
      phrases << :consular_cni_os_ireland_resident
    end
    if %w(ireland).include?(residency_country) and %w(partner_british).include?(partner_nationality) and %w(germany).exclude?(ceremony_country)
      phrases << :consular_cni_os_ireland_resident_british_partner
    end
    if %w(ireland).include?(residency_country) and %w(germany).exclude?(ceremony_country)
      phrases << :consular_cni_os_ireland_resident_two
    end
    if %w(china).include?(ceremony_country) and resident_of == "other"
      phrases << :list_of_documents_to_provide_passport_proof_of_residence_for_both
    else
      if data_query.commonwealth_country?(residency_country) or %w(ireland).include?(residency_country) and ceremony_country != residency_country and %w(germany).exclude?(ceremony_country)
        if %w(partner_british).include?(partner_nationality)
          phrases << :consular_cni_os_commonwealth_or_ireland_resident_british_partner
        else
          phrases << :consular_cni_os_commonwealth_or_ireland_resident_non_british_partner
        end
      end
      if ceremony_country == residency_country and %w(germany italy japan spain).exclude?(ceremony_country) or (data_query.non_commonwealth_country?(residency_country) and %w(ireland).exclude?(residency_country) and ceremony_country != residency_country and %w(germany).exclude?(ceremony_country))
        phrases << :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident
      end
    end

    if ceremony_country == residency_country
      if %w(japan).include?(ceremony_country)
        phrases << :japan_consular_cni_os_local_resident
        phrases << :japan_consular_cni_os_local_resident_partner_local if %w(partner_local).include?(partner_nationality)
      end
      if %w(italy).include?(ceremony_country)
        if %w(partner_local).include?(partner_nationality)
          phrases << :italy_consular_cni_os_partner_local
        elsif %w(partner_irish partner_other).include?(partner_nationality)
          phrases << :italy_consular_cni_os_partner_other_or_irish
        elsif %w(partner_british).include?(partner_nationality)
          phrases << :italy_consular_cni_os_partner_british
        end
      elsif %w(spain).include?(ceremony_country)
        phrases << :consular_cni_variant_local_resident_spain
      end
    end

    if %w(germany).exclude?(ceremony_country) and %w(other).include?(resident_of)
      phrases << :consular_cni_os_not_uk_resident_ceremony_not_germany
    end
    if %w(other).include?(resident_of)
      if %(china).include?(ceremony_country)
        phrases << :evidence_of_nationality_or_residence_china
      elsif %(germany spain).exclude?(ceremony_country)
        phrases << :consular_cni_os_other_resident_ceremony_not_germany_or_spain
      end
    end
    if ceremony_country == residency_country and %w(spain).include?(ceremony_country)
      phrases << :spain_os_consular_cni_three
    end
    if ceremony_country == residency_country
      if %w(spain germany japan).exclude?(ceremony_country)
        phrases << :consular_cni_os_local_resident_not_germany_or_spain_or_foreign_resident_not_germany
      end
    else
      if data_query.non_commonwealth_country?(residency_country) and %w(ireland).exclude?(residency_country) and %w(germany).exclude?(ceremony_country)
        phrases << :consular_cni_os_local_resident_not_germany_or_spain_or_foreign_resident_not_germany
      end
    end

    if ceremony_country == residency_country
      if %w(germany italy spain).exclude?(residency_country)
        phrases << :consular_cni_os_local_resident_not_germany_or_italy_or_spain
      elsif %w(italy).include?(residency_country)
        phrases << :consular_cni_os_local_resident_italy_two
      end
    end
    if data_query.non_commonwealth_country?(residency_country) and %w(ireland).exclude?(residency_country) and ceremony_country != residency_country
      if cni_posted_after_7_days_countries.include?(ceremony_country)
        phrases << :consular_cni_os_foreign_resident_ceremony_7_days
      elsif %w(italy germany).exclude?(ceremony_country)
        phrases << :consular_cni_os_foreign_resident_ceremony_not_italy
      elsif %w(italy).include?(ceremony_country)
        phrases << :consular_cni_os_foreign_resident_ceremony_italy
      end
    end
    if %w(italy germany).exclude?(ceremony_country)
      if data_query.commonwealth_country?(residency_country) and ceremony_country != residency_country
        phrases << :consular_cni_os_commonwealth_resident_ceremony_not_italy
      elsif %w(ireland).include?(residency_country)
        phrases << :consular_cni_os_ireland_resident_ceremony_not_italy
      end
    end
    phrases
  end

  precalculate :consular_cni_os_remainder do
    phrases = PhraseList.new
    if data_query.commonwealth_country?(residency_country) and %w(italy).include?(ceremony_country)
      phrases << :consular_cni_os_commonwealth_resident_ceremony_italy
    end
    if %w(ireland).include?(residency_country) and %w(italy).include?(ceremony_country)
      phrases << :consular_cni_os_ireland_resident_ceremony_italy
    end
    if ceremony_country == residency_country and %w(japan).include?(ceremony_country)
      phrases << :japan_consular_cni_os_local_resident_two
    end
    if data_query.commonwealth_country?(residency_country) or %w(ireland).include?(residency_country) and %w(italy).include?(ceremony_country)
      phrases << :italy_os_consular_cni_four
    end
    if %w(uk).include?(resident_of) and %w(partner_british).include?(partner_nationality) and %w(italy).exclude?(ceremony_country)
      phrases << :consular_cni_os_partner_british
    end
    if %w(partner_british).include?(partner_nationality) and %w(italy germany).exclude?(ceremony_country)
      phrases << :consular_cni_os_local_resident_ceremony_not_italy_not_germany_partner_british
    end
    if ceremony_country != residency_country and %w(other).include?(resident_of) and %w(partner_british).include?(partner_nationality) and %w(italy).include?(ceremony_country)
      phrases << :consular_cni_os_other_resident_partner_british_ceremony_italy
    end
    if %w(china).include?(ceremony_country) and %w(china).include?(residency_country) and %w(partner_local).include?(partner_nationality)
      phrases << :consular_cni_os_china_partner_local
    end
    if %w(germany).exclude?(ceremony_country) or (%w(germany).include?(ceremony_country) and %w(uk).include?(resident_of))
      phrases << :consular_cni_os_all_names_but_germany
    end

    if %w(other).include?(resident_of) and %w(italy spain germany).exclude?(ceremony_country)
      phrases << :consular_cni_os_other_resident_ceremony_not_italy
    end
    if %w(belgium).include?(ceremony_country)
      phrases << :consular_cni_os_ceremony_belgium
      if ceremony_country != residency_country
        phrases << :consular_cni_os_belgium_clickbook
      end
    end
    if %w(spain).include?(ceremony_country)
      phrases << :consular_cni_os_ceremony_spain
      if %w(partner_british).include?(partner_nationality)
        phrases << :consular_cni_os_ceremony_spain_partner_british
      end
      phrases << :consular_cni_os_ceremony_spain_two
    end
    phrases << :consular_cni_os_naturalisation if %w(partner_british).exclude?(partner_nationality)
    if not (%w(italy).include?(ceremony_country) and %w(uk).include?(resident_of))
      if %w(croatia).include?(ceremony_country) and %w(croatia).include?(residency_country)
        phrases << :fee_table_croatia
      else
        phrases << :consular_cni_os_fees_not_italy_not_uk
      end
      unless data_query.countries_without_consular_facilities?(ceremony_country)
        if ceremony_country == residency_country or %w(uk).include?(resident_of)
          if not %w(cote-d-ivoire).include?(ceremony_country)
            if %w(monaco).include?(ceremony_country)
              phrases << :list_of_consular_fees_france
            elsif %w(kazakhstan).include?(ceremony_country)
              phrases << :list_of_consular_kazakhstan
            else
              phrases << :list_of_consular_fees
            end
          end
        else
          if %w(kazakhstan).include?(ceremony_country)
            phrases << :consular_cni_os_fees_foreign_commonwealth_roi_resident_kazakhstan
          else
            phrases << :consular_cni_os_fees_foreign_commonwealth_roi_resident
          end
        end
      end
    end
    if not data_query.countries_without_consular_facilities?(ceremony_country)
      if %w(armenia bosnia-and-herzegovina cambodia iceland kazakhstan latvia luxembourg slovenia tunisia tajikistan).include?(ceremony_country)
        phrases << :pay_in_local_currency_ceremony_country_name
      elsif %w(russia).include?(ceremony_country)
        phrases << :consular_cni_os_fees_russia
      elsif %w(cote-d-ivoire).exclude?(ceremony_country)
        phrases << :pay_by_cash_or_credit_card_no_cheque
      end
    end
    phrases
  end
end

outcome :outcome_os_france_or_fot do
  precalculate :france_or_fot_os_outcome do
    phrases = PhraseList.new
    if data_query.french_overseas_territories?(ceremony_country)
      phrases << :fot_os_all
    end
    phrases
  end
end

outcome :outcome_os_affirmation do
  precalculate :affirmation_os_outcome do
    phrases = PhraseList.new
    if %w(portugal).include?(ceremony_country)
      phrases << :contact_civil_register_office_portugal
    elsif %w(uk).include?(resident_of)
      phrases << :affirmation_os_uk_resident
    elsif (ceremony_country == residency_country) or %w(qatar).include?(ceremony_country)
      phrases << :affirmation_os_local_resident
      if %w(qatar).include?(ceremony_country)
        phrases << :gulf_states_os_consular_cni << :gulf_states_os_consular_cni_local_resident_partner_not_irish
      end
    elsif ceremony_country != residency_country and %w(uk).exclude?(resident_of)
      phrases << :affirmation_os_other_resident
    end
    phrases << :affirmation_os_all_what_you_need_to_do
    phrases << :affirmation_os_uae if %w(united-arab-emirates).include?(ceremony_country)
#What you need to do section
    if %w(south-korea).include?(ceremony_country)
      phrases << :what_you_need_to_do_will_ask
    elsif %w(turkey egypt).include?(ceremony_country)
      phrases << :what_you_need_to_do
    else
      phrases << :what_you_need_to_do_may_ask
    end
    if %w(turkey).include?(ceremony_country) and %w(uk).include?(resident_of)
      phrases << :appointment_for_affidavit_notary
    elsif %w(portugal).include?(residency_country)
      phrases << :book_online_portugal
    elsif %w(philippines).include?(ceremony_country)
      phrases << :contact_for_affidavit << :make_appointment_online_philippines
    else
      if %w(portugal).include?(ceremony_country)
        phrases << :book_online_portugal
      elsif %w(egypt).include?(ceremony_country)
        phrases << :make_an_appointment
      else
        phrases << :appointment_for_affidavit
      end
      if %w(turkey).include?(ceremony_country)
        phrases << :affirmation_appointment_book_at_following
      end
    end
    if %w(finland).include?(ceremony_country)
      multiple_clickbooks ? phrases << :clickbook_links : phrases << :clickbook_link
    end
    if not (%w(turkey).include?(ceremony_country) or %w(portugal).include?(residency_country))
      if %w(portugal).include?(ceremony_country)
        phrases << :affirmation_os_translation_in_local_language_portugal
      elsif %w(egypt).include?(ceremony_country)
        phrases << :embassies_data
      else
        phrases << :affirmation_os_translation_in_local_language
      end
    end
    phrases << :affirmation_os_download_affidavit_philippines if %w(philippines).include?(ceremony_country)
    if %w(turkey).include?(ceremony_country)
      phrases << :complete_affidavit << :download_affidavit
      if %w(turkey).include?(residency_country)
        phrases << :affirmation_os_legalised_in_turkey
      else
        phrases << :affirmation_os_legalised
      end
    end
    if %w(turkey).include?(ceremony_country)
      phrases << :documents_for_divorced_or_widowed
    else
      phrases << :docs_decree_and_death_certificate
      phrases << :divorced_or_widowed_evidences unless %w(egypt).include?(ceremony_country)
      phrases << :change_of_name_evidence
      if %w(egypt).include?(ceremony_country)
        if %w(partner_british).include?(partner_nationality)
          phrases << :partner_declaration
        else
          phrases << :partner_equivalent_document
        end
      end
    end
    if not %w(egypt).include?(ceremony_country)
      if %w(turkey).include?(ceremony_country)
        if not %w(partner_british).include?(partner_nationality)
          phrases << :affirmation_os_partner_not_british_turkey
        else
          phrases << :affirmation_os_partner
        end
      else
        if not %w(partner_british).include?(partner_nationality)
          phrases << :affirmation_os_partner_not_british
        else
          phrases << :affirmation_os_partner_british
        end
      end
    end
#fee tables
    if %w(turkey vietnam thailand south-korea).include?(ceremony_country)
      phrases << :fee_table_affidavit_55
    elsif %w(philippines).include?(ceremony_country)
      phrases << :fee_table_55_70
    elsif %w(qatar).include?(ceremony_country)
      phrases << :fee_table_45_70_55
    elsif %w(egypt).include?(ceremony_country)
      phrases << :fee_table_45_55
    else
      phrases << :affirmation_os_all_fees_45_70
    end
    unless data_query.countries_without_consular_facilities?(ceremony_country)
      if %w(monaco).include?(ceremony_country)
        phrases << :list_of_consular_fees_france
      else
        phrases << :list_of_consular_fees
      end
      if %w(finland).include?(ceremony_country)
        phrases << :pay_in_euros_or_visa_electron
      elsif %w(philippines).include?(ceremony_country)
        phrases << :pay_in_cash_or_manager_cheque
      else
        phrases << :pay_by_cash_or_credit_card_no_cheque
      end
    end
    phrases
  end
end

outcome :outcome_os_no_cni do
  precalculate :no_cni_os_outcome do
    phrases = PhraseList.new
    if data_query.dutch_caribbean_islands?(ceremony_country)
      phrases << :no_cni_os_dutch_caribbean_islands
      if %w(uk).include?(resident_of)
        phrases << :no_cni_os_dutch_caribbean_islands_uk_resident
      elsif (ceremony_country == residency_country) or %w(netherlands).include?(residency_country)
        phrases << :no_cni_os_dutch_caribbean_islands_local_resident
      elsif ceremony_country != residency_country and %w(uk).exclude?(resident_of)
        phrases << :no_cni_os_dutch_caribbean_other_resident
      end
    else
      if %w(uk).include?(resident_of)
        phrases << :no_cni_os_not_dutch_caribbean_islands_uk_resident
      elsif ceremony_country == residency_country
        phrases << :no_cni_os_not_dutch_caribbean_islands_local_resident
      elsif ceremony_country != residency_country and %w(uk).exclude?(resident_of)
        phrases << :no_cni_os_not_dutch_caribbean_other_resident
      end
    end
    phrases << :get_legal_advice << :cni_os_consular_facilities_unavailable
    unless data_query.countries_without_consular_facilities?(ceremony_country)
      if %w(monaco).include?(ceremony_country)
        phrases << :list_of_consular_fees_france
      else
        phrases << :list_of_consular_fees
      end
      phrases << :pay_by_cash_or_credit_card_no_cheque
    end
    if %w(partner_british).exclude?(partner_nationality)
      phrases << :no_cni_os_naturalisation
    end
    phrases
  end
end

outcome :outcome_os_other_countries do
  precalculate :other_countries_os_outcome do
    phrases = PhraseList.new
    if %w(burma).include?(ceremony_country)
      phrases << :other_countries_os_burma
      if %w(partner_local).include?(partner_nationality)
        phrases << :other_countries_os_burma_partner_local
      end
    elsif %w(north-korea).include?(ceremony_country)
      phrases << :other_countries_os_north_korea
      if %w(partner_local).include?(partner_nationality)
        phrases << :other_countries_os_north_korea_partner_local
      end
    elsif %w(iran somalia syria).include?(ceremony_country)
      phrases << :other_countries_os_iran_somalia_syria
    elsif %w(yemen).include?(ceremony_country)
      phrases << :other_countries_os_yemen
    end
    if %w(saudi-arabia).include?(ceremony_country)
      if ceremony_country != residency_country
        phrases << :other_countries_os_ceremony_saudia_arabia_not_local_resident
      else
        if %w(partner_irish).include?(partner_nationality)
          phrases << :other_countries_os_saudi_arabia_local_resident_partner_irish
        else
          phrases << :other_countries_os_saudi_arabia_local_resident_partner_not_irish
        end
        if %w(partner_irish partner_british).exclude?(partner_nationality)
          phrases << :other_countries_os_saudi_arabia_local_resident_partner_not_irish_or_british
        end
        if %w(partner_irish).exclude?(partner_nationality)
          phrases << :other_countries_os_saudi_arabia_local_resident_partner_not_irish_two
        end
      end
    end
    phrases
  end
end

#CP outcomes
outcome :outcome_cp_cp_or_equivalent do
  precalculate :cp_or_equivalent_cp_outcome do
    phrases = PhraseList.new
    if data_query.cp_equivalent_countries?(ceremony_country)
      phrases << :"cp_or_equivalent_cp_#{ceremony_country}"
    end
    if %w(uk).include?(resident_of)
      phrases << :cp_or_equivalent_cp_uk_resident
    elsif ceremony_country == residency_country
      phrases << :cp_or_equivalent_cp_local_resident
    elsif ceremony_country != residency_country and %w(uk).exclude?(resident_of)
      phrases << :cp_or_equivalent_cp_other_resident
    end
    phrases << :cp_or_equivalent_cp_all_what_you_need_to_do
    if %w(partner_british).exclude?(partner_nationality)
      phrases << :cp_or_equivalent_cp_naturalisation
    end
    phrases << :cp_or_equivalent_cp_all_fees
    if not (%w{czech-republic}.include?(ceremony_country) || data_query.countries_without_consular_facilities?(ceremony_country))
      if %w(monaco).include?(ceremony_country)
        phrases << :list_of_consular_fees_france
      else
        phrases << :list_of_consular_fees
      end
    end
    if %w(iceland luxembourg slovenia).include?(ceremony_country)
      phrases << :pay_in_local_currency
    elsif %w(czech-republic cote-d-ivoire).exclude?(ceremony_country)
      phrases << :pay_by_cash_or_credit_card_no_cheque
    end
    phrases
  end
end
outcome :outcome_cp_france_pacs do
  precalculate :france_pacs_law_cp_outcome do
    PhraseList.new(:fot_cp_all) if %w(new-caledonia wallis-and-futuna).include?(ceremony_country)
  end
end

outcome :outcome_cp_no_cni do
  precalculate :no_cni_required_cp_outcome do
    phrases = PhraseList.new
    phrases << :"no_cni_required_cp_#{ceremony_country}" if data_query.cp_cni_not_required_countries?(ceremony_country)
    phrases << :no_cni_required_all_legal_advice
    phrases << :no_cni_required_cp_ceremony_us if %w(usa).include?(ceremony_country)
    phrases << :no_cni_required_all_what_you_need_to_do
    if %w(bonaire-st-eustatius-saba).include?(ceremony_country)
      phrases << :no_cni_required_cp_dutch_islands
      if %w(uk).include?(resident_of)
        phrases << :no_cni_required_cp_dutch_islands_uk_resident
      elsif ceremony_country == residency_country
        phrases << :no_cni_required_cp_dutch_islands_local_resident
      elsif ceremony_country != residency_country and %w(uk).exclude?(resident_of)
        phrases << :no_cni_required_cp_dutch_islands_other_resident
      end
    else
      if %w(uk).include?(resident_of)
        phrases << :no_cni_required_cp_not_dutch_islands_uk_resident
      elsif ceremony_country == residency_country
        phrases << :no_cni_required_cp_not_dutch_islands_local_resident
      elsif ceremony_country != residency_country and %w(uk).exclude?(resident_of)
        phrases << :no_cni_required_cp_not_dutch_islands_other_resident
      end
    end
    phrases << :no_cni_required_cp_all_consular_facilities
    phrases << :no_cni_required_cp_naturalisation if %w(partner_british).exclude?(partner_nationality)
    phrases
  end
end

outcome :outcome_cp_commonwealth_countries do
  precalculate :commonwealth_countries_cp_outcome do
    phrases = PhraseList.new
    if %w(australia).include?(ceremony_country)
      phrases << :commonwealth_countries_cp_australia
    elsif %w(canada).include?(ceremony_country)
      phrases << :commonwealth_countries_cp_canada
    elsif %w(new-zealand).include?(ceremony_country)
      phrases << :commonwealth_countries_cp_new_zealand
    elsif %w(south-africa).include?(ceremony_country)
      phrases << :commonwealth_countries_cp_south_africa
    end
    phrases << :commonwealth_countries_cp_australia_two if %w(australia).include?(ceremony_country)
    if %w(uk).include?(resident_of)
      phrases << :commonwealth_countries_cp_uk_resident_two
    elsif ceremony_country == residency_country
      phrases << :commonwealth_countries_cp_local_resident
    elsif ceremony_country != residency_country and %w(uk).exclude?(resident_of)
      phrases << :commonwealth_countries_cp_other_resident
    end
    if %w(australia).include?(ceremony_country)
      phrases << :commonwealth_countries_cp_australia_three
      phrases << :commonwealth_countries_cp_australia_four
      if %w(partner_local).include?(partner_nationality)
        phrases << :commonwealth_countries_cp_australia_partner_local
      elsif %w(partner_other).include?(partner_nationality)
        phrases << :commonwealth_countries_cp_australia_partner_other
      end
      phrases << :commonwealth_countries_cp_australia_five
    end
    phrases << :embassies_data if not %w(australia).include?(ceremony_country)
    phrases << :commonwealth_countries_cp_naturalisation if %w(partner_british).exclude?(partner_nationality)
    phrases << :commonwealth_countries_cp_australia_six if %w(australia).include?(ceremony_country)
    phrases
  end
end

outcome :outcome_cp_consular do
  precalculate :consular_cp_outcome do
    phrases = PhraseList.new
    phrases << :consular_cp_ceremony
    if %w(vietnam).include?(ceremony_country)
      phrases << :consular_cp_ceremony_vietnam_partner_local if %w(partner_local).include?(partner_nationality)
      phrases << :consular_cp_vietnam
    elsif %w(croatia bulgaria).include?(ceremony_country) and %w(partner_local).include?(partner_nationality)
      phrases << :consular_cp_local_partner_croatia_bulgaria
    elsif %w(japan).include?(ceremony_country)
      phrases << :consular_cp_japan
    else
      phrases << :consular_cp_all_contact
      if reg_data_query.clickbook(ceremony_country)
        multiple_clickbooks ? phrases << :clickbook_links : phrases << :clickbook_link
      end
    end
    phrases << :embassies_data if not reg_data_query.clickbook(ceremony_country)
    phrases << :consular_cp_all_documents unless %w(japan).include?(ceremony_country)
    phrases << :consular_cp_partner_not_british if %w(partner_british).exclude?(partner_nationality)
    phrases << :consular_cp_all_what_you_need_to_do
    phrases << :consular_cp_naturalisation if not %w(partner_british).include?(partner_nationality)
    if %w(vietnam thailand south-korea).include?(ceremony_country)
      phrases << :fee_table_affidavit_55
    else
      phrases << :consular_cp_all_fees
    end
    if %w(cambodia latvia).include?(ceremony_country)
      phrases << :pay_in_local_currency
    else
      phrases << :pay_by_cash_or_credit_card_no_cheque
    end
    phrases
  end
end

outcome :outcome_cp_all_other_countries

outcome :outcome_ss_marriage do
  precalculate :ss_title do
    PhraseList.new(:"title_#{marriage_and_partnership_phrases}")
  end

  precalculate :ss_fees_table do
    if data_query.ss_alt_fees_table_country?(ceremony_country, partner_nationality)
      :"#{marriage_and_partnership_phrases}_alt"
    else
      :"#{marriage_and_partnership_phrases}"
    end
  end

  precalculate :ss_ceremony_body do
    phrases = PhraseList.new
    phrases << :"able_to_#{marriage_and_partnership_phrases}"
    if %w(japan).include?(ceremony_country)
      phrases << :consular_cp_japan
    elsif data_query.ss_clickbook_countries?(ceremony_country)
      phrases << :"book_online_#{ceremony_country}"
    else
      phrases << :contact_embassy_or_consulate << :embassies_data
    end
    unless %w(japan).include?(ceremony_country)
      if %w(partner_british).include?(partner_nationality)
        phrases << :documents_needed_ss_british
      else
        phrases << :documents_needed_ss_not_british
      end
    end
    phrases << :"what_to_do_#{marriage_and_partnership_phrases}" << :will_display_in_14_days << :"no_objection_in_14_days_#{marriage_and_partnership_phrases}" << :"provide_two_witnesses_#{marriage_and_partnership_phrases}"
    phrases << :australia_ss_relationships if %w(australia).include?(ceremony_country)
    phrases << :ss_marriage_footnote << :partner_naturalisation_in_uk << :"fees_table_#{ss_fees_table}" << :list_of_consular_fees << :pay_by_cash_or_credit_card_no_cheque
    phrases
  end
end

outcome :outcome_ss_marriage_not_possible
