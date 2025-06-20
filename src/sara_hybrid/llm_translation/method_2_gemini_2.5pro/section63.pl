:- module(section63,
          [
            s63_taxable_income/4,
            s63_standard_deduction/4,
            s63_c_basic_standard_deduction/4,
            s63_f_additional_amounts_total/4,   % CORRECTED: Export the defined predicate
            s63_f_2_A_applies/3
          ]).

:- use_module(section2, [s2_a_is_surviving_spouse/3, s2_b_is_head_of_household/3]).
:- use_module(section151, [s151_total_personal_exemptions_deduction/4, s151_is_allowable_as_dependent_to_another/3]).
:- use_module(section7703, [s7703_is_married_gen_rule/3]). % For marital status for s63(f)
:- use_module(helpers, [tcja_active/1]).

% (a) In general (itemizers)
s63_taxable_income(CaseID, TaxpayerID, TaxYear, TaxableIncome) :-
    fact(CaseID, itemizes_deductions(TaxpayerID, TaxYear)),
    fact(CaseID, gross_income(TaxpayerID, TaxYear, GrossIncome)),
    s63_d_itemized_deductions_net(CaseID, TaxpayerID, TaxYear, ItemizedDeductions), % After S68 limit if applicable
    % The text says "gross income minus the deductions allowed by this chapter (other than the standard deduction)"
    % This implies AGI - itemized deductions. Personal exemptions are separate.
    % However, S63(d) defines itemized deductions as "other than ... deduction for personal exemptions".
    % Traditionally: GrossIncome - AboveLineDeductions = AGI.
    % TI = AGI - ItemizedDeductions - PersonalExemptions.
    % The text "gross income minus the deductions allowed by this chapter (other than the standard deduction)" is a bit ambiguous.
    % Let's assume GrossIncome here is effectively AGI for simplicity if not otherwise specified.
    % And "deductions allowed" means itemized deductions AND personal exemptions.
    % However, S63(a) says "other than standard deduction", S63(b) subtracts std ded AND personal exemptions from AGI.
    % This suggests S63(a) TI = AGI - Itemized Deductions. (Where AGI = Gross Income - specific above-the-line deductions).
    % And Sec 151 says exemptions are "allowed as deductions in computing taxable income."
    % So, TI = AGI - ItemizedDeductions - PersonalExemptions for itemizers too.
    s151_total_personal_exemptions_deduction(CaseID, TaxpayerID, TaxYear, PersonalExemptions),
    TaxableIncome is GrossIncome - ItemizedDeductions - PersonalExemptions.

% (b) Individuals who do not itemize
s63_taxable_income(CaseID, TaxpayerID, TaxYear, TaxableIncome) :-
    \+ fact(CaseID, itemizes_deductions(TaxpayerID, TaxYear)), % Does not elect to itemize
    fact(CaseID, adjusted_gross_income(TaxpayerID, TaxYear, AGI)), % Or gross_income if AGI not specified
    s63_standard_deduction(CaseID, TaxpayerID, TaxYear, StandardDeduction),
    s151_total_personal_exemptions_deduction(CaseID, TaxpayerID, TaxYear, PersonalExemptions),
    TaxableIncome is AGI - StandardDeduction - PersonalExemptions.

% (c) Standard deduction
s63_standard_deduction(CaseID, TaxpayerID, TaxYear, StandardDeduction) :-
    \+ s63_c_6_not_eligible_for_standard_deduction(CaseID, TaxpayerID, TaxYear),
    s63_c_1_standard_deduction_sum(CaseID, TaxpayerID, TaxYear, RawStandardDeduction),
    (   s151_is_allowable_as_dependent_to_another(CaseID, TaxpayerID, TaxYear) ->
        s63_c_5_limitation_for_dependents(CaseID, TaxpayerID, TaxYear, RawStandardDeduction, StandardDeduction)
    ;   StandardDeduction = RawStandardDeduction
    ).
s63_standard_deduction(CaseID, TaxpayerID, TaxYear, 0) :- % Standard deduction is zero if not eligible
    s63_c_6_not_eligible_for_standard_deduction(CaseID, TaxpayerID, TaxYear).


s63_c_1_standard_deduction_sum(CaseID, TaxpayerID, TaxYear, StandardDeduction) :-
    s63_c_basic_standard_deduction(CaseID, TaxpayerID, TaxYear, BasicStandardDeduction),
    s63_c_additional_standard_deduction(CaseID, TaxpayerID, TaxYear, AdditionalStandardDeduction),
    StandardDeduction is BasicStandardDeduction + AdditionalStandardDeduction.

s63_c_basic_standard_deduction(CaseID, TaxpayerID, TaxYear, BasicStdDed) :-
    fact(CaseID, filing_status(TaxpayerID, TaxYear, FilingStatus)),
    s63_c_2_basic_standard_deduction_amount(FilingStatus, TaxYear, BasicStdDed).

s63_c_2_basic_standard_deduction_amount(FilingStatus, TaxYear, Amount) :-
    ( FilingStatus = married_filing_jointly ; FilingStatus = surviving_spouse ),
    s63_c_2_C_amount(TaxYear, BaseSingleAmount),
    Amount is 2 * BaseSingleAmount. % (A) 200 percent of (C)

s63_c_2_basic_standard_deduction_amount(head_of_household, TaxYear, Amount) :- % (B)
    ( tcja_active(TaxYear) -> Amount = 18000 ; Amount = 4400 ). % (c)(7)(i)

s63_c_2_basic_standard_deduction_amount(FilingStatus, TaxYear, Amount) :- % (C) any other case (single, mfs)
    member(FilingStatus, [single, married_filing_separately]), % Explicitly
    s63_c_2_C_amount(TaxYear, Amount).

s63_c_2_C_amount(TaxYear, Amount) :- % Base amount for (C)
    ( tcja_active(TaxYear) -> Amount = 12000 ; Amount = 3000 ). % (c)(7)(ii)


s63_c_additional_standard_deduction(CaseID, TaxpayerID, TaxYear, AdditionalStandardDeduction) :-
    s63_f_additional_amounts_total(CaseID, TaxpayerID, TaxYear, AdditionalStandardDeduction).

s63_c_5_limitation_for_dependents(CaseID, TaxpayerID, TaxYear, BasicStandardDeductionFromStatus, LimitedBSD) :-
    fact(CaseID, earned_income(TaxpayerID, TaxYear, EarnedIncome)),
    GreaterOfAmount is max(500, 250 + EarnedIncome),
    LimitedBSD is min(BasicStandardDeductionFromStatus, GreaterOfAmount).

s63_c_6_not_eligible_for_standard_deduction(CaseID, TaxpayerID, TaxYear) :-
    s63_c_6_A_mfs_spouse_itemizes(CaseID, TaxpayerID, TaxYear).
s63_c_6_not_eligible_for_standard_deduction(CaseID, TaxpayerID, TaxYear) :-
    s63_c_6_B_nra(CaseID, TaxpayerID, TaxYear).
% (D) estate/trust not modeled for individuals

s63_c_6_A_mfs_spouse_itemizes(CaseID, TaxpayerID, TaxYear) :-
    fact(CaseID, filing_status(TaxpayerID, TaxYear, married_filing_separately)),
    fact(CaseID, spouse_of(TaxpayerID, SpouseID)),
    fact(CaseID, itemizes_deductions(SpouseID, TaxYear)).

s63_c_6_B_nra(CaseID, TaxpayerID, TaxYear) :-
    fact(CaseID, is_nonresident_alien(TaxpayerID, TaxYear)).

% (d) Itemized deductions (placeholder, actual deductions complex)
s63_d_itemized_deductions_net(CaseID, TaxpayerID, TaxYear, NetItemizedDeductions) :-
    fact(CaseID, itemized_deductions_gross(TaxpayerID, TaxYear, GrossItemizedDeductions)),
    ( fact(CaseID, adjusted_gross_income(TaxpayerID, TaxYear, AGI)), \+ tcja_active(TaxYear) -> % S68 applies pre-2018
        catch(user:s68_apply_limitation(CaseID, TaxpayerID, TaxYear, AGI, GrossItemizedDeductions, NetItemizedDeductions), _, NetItemizedDeductions = GrossItemizedDeductions) % call s68 if loaded
    ; NetItemizedDeductions = GrossItemizedDeductions % S68 does not apply
    ).


% (f) Aged or blind additional amounts
s63_f_additional_amounts_total(CaseID, TaxpayerID, TaxYear, TotalAmount) :-
    s63_f_taxpayer_amount(CaseID, TaxpayerID, TaxYear, TaxpayerAmount),
    s63_f_spouse_amount(CaseID, TaxpayerID, TaxYear, SpouseAmount), % SpouseAmount is 0 if no spouse or spouse not eligible
    TotalAmount is TaxpayerAmount + SpouseAmount.

s63_f_taxpayer_amount(CaseID, TaxpayerID, TaxYear, Amount) :-
    s63_f_get_base_amount_per_condition(CaseID, TaxpayerID, TaxYear, BasePerCondition),
    ( fact(CaseID, taxpayer_is_aged(TaxpayerID, TaxYear)) -> Aged = BasePerCondition ; Aged = 0 ),
    ( fact(CaseID, taxpayer_is_blind(TaxpayerID, TaxYear)) -> Blind = BasePerCondition ; Blind = 0 ),
    Amount is Aged + Blind. % Can be double if aged AND blind

s63_f_spouse_amount(CaseID, TaxpayerID, TaxYear, Amount) :-
    ( fact(CaseID, spouse_of(TaxpayerID, SpouseID)),
      s151_is_entitled_to_deduction_for_dependent(CaseID, TaxpayerID, SpouseID, TaxYear) % "additional exemption is allowable...for such spouse under 151(b)"
      % Note: s151(b) has conditions: joint return not made, spouse no gross income, spouse not dependent of another.
      % This check needs to correctly reflect s151(b) for the spouse.
      % For simplicity, we'll assume a fact `can_claim_exemption_for_spouse_s151b(TaxpayerID, SpouseID, TaxYear)`
      % exists if this level of detail is needed for a case.
      % Or, more directly, a fact for whether additional exemption is allowable for spouse.
    ; fact(CaseID, is_married_and_additional_exemption_allowable_for_spouse(TaxpayerID, SpouseID, TaxYear)) % Simplified fact
    ),
    s63_f_get_base_amount_per_condition_for_spouse(CaseID, TaxpayerID, TaxYear, BasePerCondition), % Spouse uses taxpayer's marital status for $600/$750 determination
    ( fact(CaseID, spouse_is_aged(SpouseID, TaxYear)) -> Aged = BasePerCondition ; Aged = 0 ),
    ( fact(CaseID, spouse_is_blind(SpouseID, TaxYear)) -> Blind = BasePerCondition ; Blind = 0 ), % Blindness determined at death if spouse died.
    Amount is Aged + Blind.
s63_f_spouse_amount(CaseID, TaxpayerID, TaxYear, Amount) :-
    fact(CaseID, spouse_of(TaxpayerID, SpouseID)), % Check if THIS taxpayer has a spouse
    fact(CaseID, is_married_and_additional_exemption_allowable_for_spouse(TaxpayerID, SpouseID, TaxYear)), % Ensured this fact covers s151(b) conditions
    s63_f_get_base_amount_per_condition_for_spouse(CaseID, TaxpayerID, TaxYear, BasePerCondition),
    ( fact(CaseID, spouse_is_aged(SpouseID, TaxYear)) -> Aged = BasePerCondition ; Aged = 0 ),
    ( fact(CaseID, spouse_is_blind(SpouseID, TaxYear)) -> Blind = BasePerCondition ; Blind = 0 ),
    Amount is Aged + Blind.
s63_f_spouse_amount(CaseID, TaxpayerID, TaxYear, 0) :- % Case: Taxpayer has a spouse BUT additional exemption not allowable
    fact(CaseID, spouse_of(TaxpayerID, SpouseID)),
    \+ fact(CaseID, is_married_and_additional_exemption_allowable_for_spouse(TaxpayerID, SpouseID, TaxYear)).
s63_f_spouse_amount(CaseID, TaxpayerID, _TaxYear, 0) :- % Case: Taxpayer has NO spouse
    \+ fact(CaseID, spouse_of(TaxpayerID, _)).
% Default fallback, though the above should cover all.
s63_f_spouse_amount(_CaseID, _TaxpayerID, _TaxYear, 0).

s63_f_get_base_amount_per_condition(CaseID, TaxpayerID, TaxYear, Amount) :-
    ( (\+ s7703_is_married_gen_rule(CaseID, TaxpayerID, TaxYear), \+ s2_a_is_surviving_spouse(CaseID, TaxpayerID, TaxYear)) -> % Unmarried and not SS
        Amount = 750 % (f)(3)
    ; Amount = 600
    ).

% For spouse, the $600/$750 amount depends on the FILER's status (TaxpayerID)
s63_f_get_base_amount_per_condition_for_spouse(CaseID, TaxpayerID, TaxYear, Amount) :-
    s63_f_get_base_amount_per_condition(CaseID, TaxpayerID, TaxYear, Amount).


% For specific case question s63_f_2_A_neg
s63_f_2_A_applies(CaseID, PersonID, TaxYear) :-
    s63_f_get_base_amount_per_condition(CaseID, PersonID, TaxYear, BaseAmount), % Base amount for this person if they were the taxpayer
    BaseAmount > 0, % to ensure this rule path is taken
    fact(CaseID, taxpayer_is_blind(PersonID, TaxYear)). % (A) for himself if he is blind

% Helper: is_aged check
fact(CaseID, taxpayer_is_aged(PersonID, TaxYear)) :-
    age_at_year_end(CaseID, PersonID, TaxYear, Age),
    Age >= 65.
fact(CaseID, spouse_is_aged(SpouseID, TaxYear)) :- % Assuming SpouseID is known
    age_at_year_end(CaseID, SpouseID, TaxYear, Age),
    Age >= 65.

% Helper: is_blind check
fact(CaseID, taxpayer_is_blind(PersonID, TaxYear)) :- % Taxpayer is PersonID
    fact(CaseID, is_blind(PersonID, TaxYear)). % fact(case_id, is_blind(person_id, tax_year_integer)).
fact(CaseID, spouse_is_blind(SpouseID, TaxYear)) :-
    fact(CaseID, is_blind(SpouseID, TaxYear)). % Add handling for "time of death" if needed by a case