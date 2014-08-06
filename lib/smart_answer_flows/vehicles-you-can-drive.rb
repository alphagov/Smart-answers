status :published
satisfies_need "100242"

## Q1
multiple_choice :what_type_of_vehicle? do
  option "car-or-light-vehicle" => :how_old_are_you? #Q3
  option motorcycle: :how_old_are_you_mb? #Q4
  option moped: :do_you_have_a_full_driving_licence? #Q9
  option "medium-sized-vehicle" => :do_you_have_a_full_cat_b_driving_licence? #Q12
  option "large-vehicle-or-lorry" => :how_old_are_you_lorry? #Q15
  option minibus: :when_was_licence_issued_psv? #Q18
  option bus: :full_cat_b_licence_bus? #Q21
  option tractor: :full_cat_b_licence_tractor? #Q23
  option "specialist-vehicle" => :full_cat_b_licence_sv? #Q25
  option "quad-bike" => :full_cat_b_licence_quad? #Q28
  option "trike" => :full_cat_b_licence_trike? # Q30
end

## Q2 Cars
multiple_choice :how_old_are_you? do
  option "under-16" => :not_old_enough #A1
  option "16" => :mobility_rate_clause #A2
  option "17-or-over" => :entitled_for_provisional_licence #A3
end

## Q3 Motorcycles
multiple_choice :how_old_are_you_mb? do
  option "under-17" => :mb_not_old_enough # A5
  option "17-18" => :mb_apply_provisional # A6
  option "19-23" => :mb_apply_provisional_a1_a2 #A7
  option "24-or-over" => :mb_apply_provisional_any #A9
end

## Q4 Mopeds
multiple_choice :do_you_have_a_full_driving_licence? do
  option yes: :licence_issued_before_2001? # Q10
  option no: :how_old_are_you_mpd? # Q11
end

## Q5
multiple_choice :licence_issued_before_2001? do
  option yes: :moped_entitlement_licence_pre_2001 # A13
  option no: :moped_entitlement_licence_post_2001 # A14
end

## Q6
multiple_choice :how_old_are_you_mpd? do
  option "under-16" => :moped_not_old_enough # A15
  option "16-or-over" => :moped_apply_for_provisional # A16
end

## Q7 Medium sized vehicles
multiple_choice :do_you_have_a_full_cat_b_driving_licence? do
  option yes: :when_was_licence_issued? # Q13
  option no: :cat_b_licence_required # A20
end

## Q8
multiple_choice :when_was_licence_issued? do
  option "before-jan-1997" => :entitled_for_msv # A17
  option "from-jan-1997" => :how_old_are_you_msv? # Q14
end

## Q9
multiple_choice :how_old_are_you_msv? do
  option "under-18" => :not_entitled_for_msv_until_18 # A18
  option "18-or-over" => :apply_for_provisional_msv_entitlement # A19
end

## Q10 Lorries and large vehicles
multiple_choice :how_old_are_you_lorry? do
  option "under-18" => :not_entitled_for_lorry_until_18 # A21
  option "18-20" => :limited_entitlement_lorry # A22
  option "21-or-over" => :do_you_have_a_full_cat_b_car_licence? # Q16
end

## Q11
multiple_choice :do_you_have_a_full_cat_b_car_licence? do
  option yes: :apply_for_provisional_cat_c_entitlement #A23
  option no: :cat_b_driving_licence_required # A25
end

## Q12 Minibus PSV
multiple_choice :when_was_licence_issued_psv? do
  option "before-jan-1997" => :has_licence_been_replaced_psv? # Q19
  option "from-jan-1997" => :does_licence_show_d1_psv? # Q20
end

## Q13
multiple_choice :has_licence_been_replaced_psv? do
  option yes: :psv_renew_entitlement # A50
  option no: :psv_entitled # A26
end

## Q14
multiple_choice :does_licence_show_d1_psv? do
  option yes: :psv_entitled # A26
  option no: :psv_entitled_cat_b # A51
end

## Q15 Bus
multiple_choice :full_cat_b_licence_bus? do
  option yes: :how_old_are_you_bus? # Q22
  option no: :bus_apply_for_cat_b # A33
end

## Q16
multiple_choice :how_old_are_you_bus? do
  option "under-24" => :bus_exceptions_under_24 # A29
  option "24-or-above" => :bus_apply_for_cat_d # A32
end

## Q17 Tractor
multiple_choice :full_cat_b_licence_tractor? do
  option yes: :tractor_entitled # A34
  option no: :how_old_are_you_tractor? # Q24
end

## Q18
multiple_choice :how_old_are_you_tractor? do
  option "under-16" => :tractor_not_old_enough # A35
  option "16" => :tractor_apply_for_provisional_conditional_licence # A36
  option "17-or-over" => :tractor_apply_for_provisional_entitlement # A37
end

## Q19 Specialist vehicles
multiple_choice :full_cat_b_licence_sv? do
  option yes: :how_old_are_you_licence_sv? # Q26
  option no: :how_old_are_you_no_licence_sv? # Q27
end

## Q20
multiple_choice :how_old_are_you_licence_sv? do
  option "17-20" => :sv_entitled_cat_k # A38
  option "21-or-over" => :sv_entitled_cat_k_provisional_g_h # A39
end

## Q21
multiple_choice :how_old_are_you_no_licence_sv? do
  option "under-16" => :sv_not_old_enough # A40
  option "16" => :sv_entitled_cat_k_mower # A41
  option "17-20" => :sv_entitled_cat_k_conditional_g_h # A42
  option "21-or-over" => :sv_entitled_no_licence # A43
end

## Q22 Quad bikes and 4-wheeled light vehicles
multiple_choice :full_cat_b_licence_quad? do
  option yes: :quad_entitled # A44
  option no: :how_old_are_you_quad? # Q29
end

## Q23
multiple_choice :how_old_are_you_quad? do
  option "under-16" => :quad_not_old_enough # A45
  option "16" => :quad_disability_conditional_entitlement # A46
  option "17-or-over" => :quad_apply_for_provisional_entitlement # A47
end

## Q24 Motor tricycle
multiple_choice :full_cat_b_licence_trike? do
  option yes: :trike_entitled
  option no: :trike_conditional_entitlement
end

outcome :not_old_enough # A1
outcome :mobility_rate_clause # A2
outcome :entitled_for_provisional_licence # A3
outcome :mb_not_old_enough # A4
outcome :mb_apply_provisional # A5
outcome :mb_apply_provisional_a1_a2 # A6
outcome :mb_apply_provisional_any # A7
outcome :moped_entitlement_licence_pre_2001 # A8
outcome :moped_entitlement_licence_post_2001 # A9
outcome :moped_not_old_enough # A10
outcome :moped_apply_for_provisional # A11
outcome :entitled_for_msv # A12
outcome :not_entitled_for_msv_until_18 # A13
outcome :apply_for_provisional_msv_entitlement # A14
outcome :cat_b_licence_required # A15
outcome :not_entitled_for_lorry_until_18 # A16
outcome :limited_entitlement_lorry # A17
outcome :apply_for_provisional_cat_c_entitlement # A18
outcome :cat_b_driving_licence_required # A19
outcome :psv_renew_entitlement # A20
outcome :psv_entitled # A21
outcome :psv_entitled_cat_b # A22
outcome :bus_exceptions_under_24 # A23
outcome :bus_apply_for_cat_d # A24
outcome :bus_apply_for_cat_b # A25
outcome :tractor_entitled # A26
outcome :tractor_not_old_enough # A27
outcome :tractor_apply_for_provisional_conditional_licence # A28
outcome :tractor_apply_for_provisional_entitlement # A29
outcome :sv_entitled_cat_k # A30
outcome :sv_entitled_cat_k_provisional_g_h # A31
outcome :sv_not_old_enough # A32
outcome :sv_entitled_cat_k_mower # A33
outcome :sv_entitled_cat_k_conditional_g_h # A34
outcome :sv_entitled_no_licence # A35
outcome :quad_entitled # A36
outcome :quad_not_old_enough # A37
outcome :quad_disability_conditional_entitlement # A38
outcome :quad_apply_for_provisional_entitlement # A39
outcome :trike_entitled # A40
outcome :trike_conditional_entitlement # A41
