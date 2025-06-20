:- module(section63,
          [ s63_taxable_income/4,               % s63_taxable_income(CaseID, TaxpayerID, TaxYear, TaxableIncome)
            s63_c_standard_deduction/4,         % s63_c_standard_deduction(CaseID, TaxpayerID, TaxYear, StandardDeduction)
            s63_c_basic_standard_deduction/4,   % s63_c_basic_standard_deduction(CaseID, TaxpayerID, TaxYear, BSD)
            s63_f_total_additional_amount_aged_blind/4, % s63_f_total_additional_amount_aged_blind(CaseID, TaxpayerID, TaxYear, TotalAdditional)
            s63_f_2_A_blind_taxpayer_applies/4  % s63_f_2_A_blind_taxpayer_applies(CaseID, TaxpayerID, TaxYear, AppliesBool)
          ]).

:- use_module(helpers, [tcja_standard_deduction_rules_active/1, get_age_at_year_end/4]).
:- use_module(section151, [s151_total_deduction_personal_exemptions/4, s151_is_entitled_to_deduction_for_person/4]).
:- use_module(section2, [s2_a_is_surviving_spouse/4, s2_b_is_head_of_household/4]).
:- use_module(section7703, [s7703_is_married/4]).
:- use_module(section68, [s68_limitation_on_itemized_deductions/5]).

:- dynamic fact/2.

% §63(a) In general (itemizers)
s63_taxable_income(CaseID, TaxpayerID, TaxYear, TaxableIncome) :-
    fact(CaseID, elects_to_itemize_deductions(TaxpayerID, TaxYear)),
    fact(CaseID, gross_income(TaxpayerID, TaxYear, GrossIncome)), % Assuming gross_income is AGI for itemizers if AGI not separately given for them
    s63_d_itemized_deductions(CaseID, TaxpayerID, TaxYear, ItemizedDeductionsAllowed),
    s151_total_deduction_personal_exemptions(CaseID, TaxpayerID, TaxYear, PersonalExemptions),
    TaxableIncome is GrossIncome - ItemizedDeductionsAllowed - PersonalExemptions.

% §63(b) Individuals who do not itemize
s63_taxable_income(CaseID, TaxpayerID, TaxYear, TaxableIncome) :-
    \+ fact(CaseID, elects_to_itemize_deductions(TaxpayerID, TaxYear)),
    fact(CaseID, adjusted_gross_income(TaxpayerID, TaxYear, AGI)),
    s63_c_standard_deduction(CaseID, TaxpayerID, TaxYear, StandardDeduction),
    s151_total_deduction_personal_exemptions(CaseID, TaxpayerID, TaxYear, PersonalExemptions),
    TaxableIncome is AGI - StandardDeduction - PersonalExemptions.

% §63(c) Standard deduction
s63_c_standard_deduction(CaseID, TaxpayerID, TaxYear, 0) :- % §63(c)(6)
    s63_c_6_not_eligible_for_standard_deduction(CaseID, TaxpayerID, TaxYear, true).
s63_c_standard_deduction(CaseID, TaxpayerID, TaxYear, StandardDeduction) :-
    \+ s63_c_6_not_eligible_for_standard_deduction(CaseID, TaxpayerID, TaxYear, true),
    s63_c_1_calculate_standard_deduction(CaseID, TaxpayerID, TaxYear, RawStandardDeduction),
    (   fact(CaseID, is_allowable_as_section151_deduction_to_another(TaxpayerID, TaxYear, _)) % §63(c)(5) dependent limitation
    ->  s63_c_5_limitation_on_bsd_for_dependents(CaseID, TaxpayerID, TaxYear, RawStandardDeduction, StandardDeduction)
    ;   StandardDeduction = RawStandardDeduction
    ).

s63_c_1_calculate_standard_deduction(CaseID, TaxpayerID, TaxYear, StandardDeduction) :-
    s63_c_basic_standard_deduction(CaseID, TaxpayerID, TaxYear, BasicStdDed),
    s63_f_total_additional_amount_aged_blind(CaseID, TaxpayerID, TaxYear, AdditionalStdDed),
    StandardDeduction is BasicStdDed + AdditionalStdDed.

% §63(c)(2) Basic standard deduction
s63_c_basic_standard_deduction(CaseID, TaxpayerID, TaxYear, BSD) :-
    fact(CaseID, filing_status(TaxpayerID, TaxYear, FilingStatus)),
    s63_c_2_get_bsd_by_status(CaseID, TaxpayerID, FilingStatus, TaxYear, BSD).

s63_c_2_get_bsd_by_status(CaseID, TPID, married_filing_jointly, TaxYear, BSD) :- s63_c_2_A_i_bsd_joint_return(CaseID, TPID, TaxYear, BSD).
s63_c_2_get_bsd_by_status(CaseID, TPID, surviving_spouse, TaxYear, BSD) :- s63_c_2_A_ii_bsd_surviving_spouse(CaseID, TPID, TaxYear, BSD).
s63_c_2_get_bsd_by_status(_CaseID, _TPID, head_of_household, TaxYear, BSD) :- s63_c_2_B_bsd_hoh(TaxYear, BSD).
s63_c_2_get_bsd_by_status(_CaseID, _TPID, FilingStatus, TaxYear, BSD) :- % single, mfs (any other case)
    member(FilingStatus, [single, married_filing_separately]),
    s63_c_2_C_bsd_other_cases(TaxYear, BSD).

s63_c_2_A_i_bsd_joint_return(_CaseID, _TPID, TaxYear, BSD) :-
    s63_c_2_C_bsd_other_cases(TaxYear, AmountC), BSD is 2 * AmountC.
s63_c_2_A_ii_bsd_surviving_spouse(CaseID, TPID, TaxYear, BSD) :-
    s2_a_is_surviving_spouse(CaseID, TPID, TaxYear, true), % Confirm is SS
    s63_c_2_C_bsd_other_cases(TaxYear, AmountC), BSD is 2 * AmountC.
s63_c_2_B_bsd_hoh(TaxYear, 18000) :- tcja_standard_deduction_rules_active(TaxYear). % §63(c)(7)(i)
s63_c_2_B_bsd_hoh(TaxYear, 4400)  :- \+ tcja_standard_deduction_rules_active(TaxYear).
s63_c_2_C_bsd_other_cases(TaxYear, 12000) :- tcja_standard_deduction_rules_active(TaxYear). % §63(c)(7)(ii)
s63_c_2_C_bsd_other_cases(TaxYear, 3000)  :- \+ tcja_standard_deduction_rules_active(TaxYear).

% §63(c)(5) Limitation on basic standard deduction in the case of certain dependents
s63_c_5_limitation_on_bsd_for_dependents(CaseID, IndividualID, TaxYear, OriginalBSD, LimitedBSD) :-
    fact(CaseID, earned_income(IndividualID, TaxYear, EarnedIncome)),
    LimitValue is max(500, 250 + EarnedIncome),
    LimitedBSD is min(OriginalBSD, LimitValue).

% §63(c)(6) Certain individuals, etc., not eligible for standard deduction
s63_c_6_not_eligible_for_standard_deduction(CaseID, TaxpayerID, TaxYear, true) :-
    s63_c_6_A_mfs_spouse_itemizes(CaseID, TaxpayerID, TaxYear).
s63_c_6_not_eligible_for_standard_deduction(CaseID, TaxpayerID, TaxYear, true) :-
    s63_c_6_B_nra(CaseID, TaxpayerID, TaxYear).
s63_c_6_not_eligible_for_standard_deduction(_, _, _, false).

s63_c_6_A_mfs_spouse_itemizes(CaseID, TaxpayerID, TaxYear) :-
    fact(CaseID, filing_status(TaxpayerID, TaxYear, married_filing_separately)),
    fact(CaseID, spouse_of(TaxpayerID, SpouseID)),
    fact(CaseID, elects_to_itemize_deductions(SpouseID, TaxYear)).
s63_c_6_B_nra(CaseID, TaxpayerID, TaxYear) :-
    fact(CaseID, is_nonresident_alien(TaxpayerID, TaxYear)).

% §63(d) Itemized deductions
s63_d_itemized_deductions(CaseID, TaxpayerID, TaxYear, AllowedItemizedDeductions) :-
    fact(CaseID, itemized_deductions_before_s68_limit(TaxpayerID, TaxYear, GrossItemized)),
    fact(CaseID, adjusted_gross_income(TaxpayerID, TaxYear, AGI)), % Needed for S68
    s68_limitation_on_itemized_deductions(CaseID, TaxpayerID, TaxYear, AGI, GrossItemized, AllowedItemizedDeductions).

% §63(f) Aged or blind additional amounts
s63_f_total_additional_amount_aged_blind(CaseID, TaxpayerID, TaxYear, TotalAdditional) :-
    s63_f_1_additional_for_aged(CaseID, TaxpayerID, TaxYear, AgedAmount),
    s63_f_2_additional_for_blind(CaseID, TaxpayerID, TaxYear, BlindAmount),
    TotalAdditional is AgedAmount + BlindAmount.

s63_f_1_additional_for_aged(CaseID, TaxpayerID, TaxYear, Amount) :-
    s63_f_get_base_per_condition_amount(CaseID, TaxpayerID, TaxYear, BaseAmount),
    AgedSelf = ( (get_age_at_year_end(CaseID, TaxpayerID, TaxYear, Age), Age >= 65) -> BaseAmount ; 0 ),
    (   fact(CaseID, spouse_of(TaxpayerID, SpouseID)),
        s151_is_entitled_to_deduction_for_person(CaseID, TaxpayerID, SpouseID, TaxYear), % Additional exemption for spouse allowable
        get_age_at_year_end(CaseID, SpouseID, TaxYear, SpouseAge), SpouseAge >= 65
    ->  AgedSpouse = BaseAmount
    ;   AgedSpouse = 0
    ),
    Amount is AgedSelf + AgedSpouse.

s63_f_2_additional_for_blind(CaseID, TaxpayerID, TaxYear, Amount) :-
    s63_f_get_base_per_condition_amount(CaseID, TaxpayerID, TaxYear, BaseAmount),
    BlindSelf = ( fact(CaseID, is_blind(TaxpayerID, TaxYear)) -> BaseAmount ; 0 ),
    (   fact(CaseID, spouse_of(TaxpayerID, SpouseID)),
        s151_is_entitled_to_deduction_for_person(CaseID, TaxpayerID, SpouseID, TaxYear),
        s63_f_is_spouse_blind_for_deduction(CaseID, SpouseID, TaxYear)
    ->  BlindSpouse = BaseAmount
    ;   BlindSpouse = 0
    ),
    Amount is BlindSelf + BlindSpouse.

s63_f_is_spouse_blind_for_deduction(CaseID, SpouseID, TaxYear) :-
    ( fact(CaseID, date_of_death(SpouseID, date(DeathYear, _, _))), DeathYear =:= TaxYear ->
        fact(CaseID, is_blind_at_time_of_death(SpouseID, TaxYear))
    ;   fact(CaseID, is_blind(SpouseID, TaxYear)) % Blind at close of year
    ).

% §63(f)(3) Higher amount for certain unmarried individuals
s63_f_get_base_per_condition_amount(CaseID, TaxpayerID, TaxYear, 750) :-
    s7703_is_married(CaseID, TaxpayerID, TaxYear, false),
    s2_a_is_surviving_spouse(CaseID, TaxpayerID, TaxYear, false).
s63_f_get_base_per_condition_amount(_, _, _, 600). % Default

% For case s63_f_2_A_neg: Does §63(f)(2)(A) apply to Bob?
s63_f_2_A_blind_taxpayer_applies(CaseID, PersonID, TaxYear, true) :-
    fact(CaseID, is_blind(PersonID, TaxYear)). % (A) for himself if he is blind
s63_f_2_A_blind_taxpayer_applies(_, _, _, false).