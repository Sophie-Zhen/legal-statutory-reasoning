:- module(tax_code,
          [
              tax_liability/3,
              futa_tax_liability/3,
              taxable_income/3,
              filing_status/3,
              is_dependent/3,
              is_qualifying_child/3,
              is_qualifying_relative/3,
              is_surviving_spouse/2,
              is_head_of_household/2,
              is_married/3,
              standard_deduction/3,
              personal_exemption_deduction/3,
              itemized_deductions_allowed/3,
              is_employer/2,
              total_futa_wages/3
          ]).

:- discontiguous
    filing_status/3,
    is_married/3,
    is_dependent/3,
    is_qualifying_child/3,
    is_qualifying_relative/3,
    is_surviving_spouse/2,
    is_head_of_household/2,
    taxable_income/3,
    standard_deduction/3,
    basic_standard_deduction/3,
    additional_standard_deduction/3,
    personal_exemption_deduction/3,
    exemption_amount/2,
    itemized_deductions_allowed/3,
    is_employer/2,
    is_futa_employment/4,
    futa_wages/4.

% --- High-Level Predicates ---

% tax_liability(+Taxpayer, +Year, -Tax)
% Calculates the final tax liability for a given taxpayer and year.
tax_liability(Taxpayer, Year, Tax) :-
    filing_status(Taxpayer, Year, Status),
    taxable_income(Taxpayer, Year, TaxableIncome),
    tax_imposed(Status, TaxableIncome, Tax).

% futa_tax_liability(+Employer, +Year, -Tax)
% Calculates the FUTA excise tax for an employer for a calendar year.
futa_tax_liability(Employer, Year, Tax) :-
    is_employer(Employer, Year),
    total_futa_wages(Employer, Year, TotalWages),
    Tax is 0.06 * TotalWages.
futa_tax_liability(Employer, Year, 0) :-
    \+ is_employer(Employer, Year).


% --- §1. Tax imposed ---

% tax_imposed(+FilingStatus, +TaxableIncome, -Tax)
% Determines tax based on filing status and taxable income.

% (a) Married individuals filing joint returns and surviving spouses
tax_imposed(married_filing_jointly, TI, Tax) :- tax_bracket_mfj_ss(TI, Tax).
tax_imposed(surviving_spouse, TI, Tax) :- tax_bracket_mfj_ss(TI, Tax).

tax_bracket_mfj_ss(TI, Tax) :- TI =< 36900, Tax is 0.15 * TI.
tax_bracket_mfj_ss(TI, Tax) :- TI > 36900,  TI =< 89150,  Tax is 5535 + 0.28 * (TI - 36900).
tax_bracket_mfj_ss(TI, Tax) :- TI > 89150,  TI =< 140000, Tax is 20165 + 0.31 * (TI - 89150).
tax_bracket_mfj_ss(TI, Tax) :- TI > 140000, TI =< 250000, Tax is 35928.50 + 0.36 * (TI - 140000).
tax_bracket_mfj_ss(TI, Tax) :- TI > 250000, Tax is 75528.50 + 0.396 * (TI - 250000).

% (b) Heads of households
tax_imposed(head_of_household, TI, Tax) :-
    tax_bracket_hoh(TI, Tax).

tax_bracket_hoh(TI, Tax) :- TI =< 29600, Tax is 0.15 * TI.
tax_bracket_hoh(TI, Tax) :- TI > 29600,  TI =< 76400,  Tax is 4440 + 0.28 * (TI - 29600).
tax_bracket_hoh(TI, Tax) :- TI > 76400,  TI =< 127500, Tax is 17544 + 0.31 * (TI - 76400).
tax_bracket_hoh(TI, Tax) :- TI > 127500, TI =< 250000, Tax is 33385 + 0.36 * (TI - 127500).
tax_bracket_hoh(TI, Tax) :- TI > 250000, Tax is 77485 + 0.396 * (TI - 250000).

% (c) Unmarried individuals (other than surviving spouses and heads of households)
tax_imposed(single, TI, Tax) :-
    tax_bracket_single(TI, Tax).

tax_bracket_single(TI, Tax) :- TI =< 22100, Tax is 0.15 * TI.
tax_bracket_single(TI, Tax) :- TI > 22100,  TI =< 53500,  Tax is 3315 + 0.28 * (TI - 22100).
tax_bracket_single(TI, Tax) :- TI > 53500,  TI =< 115000, Tax is 12107 + 0.31 * (TI - 53500).
tax_bracket_single(TI, Tax) :- TI > 115000, TI =< 250000, Tax is 31172 + 0.36 * (TI - 115000).
tax_bracket_single(TI, Tax) :- TI > 250000, Tax is 79772 + 0.396 * (TI - 250000).

% (d) Married individuals filing separate returns
tax_imposed(married_filing_separately, TI, Tax) :-
    tax_bracket_mfs(TI, Tax).

tax_bracket_mfs(TI, Tax) :- TI =< 18450, Tax is 0.15 * TI.
tax_bracket_mfs(TI, Tax) :- TI > 18450,  TI =< 44575,  Tax is 2767.50 + 0.28 * (TI - 18450).
tax_bracket_mfs(TI, Tax) :- TI > 44575,  TI =< 70000,  Tax is 10082.50 + 0.31 * (TI - 44575).
tax_bracket_mfs(TI, Tax) :- TI > 70000,  TI =< 125000, Tax is 17964.25 + 0.36 * (TI - 70000).
tax_bracket_mfs(TI, Tax) :- TI > 125000, Tax is 37764.25 + 0.396 * (TI - 125000).


% --- §63. Taxable income defined ---

% (a) In general
taxable_income(Taxpayer, Year, TaxableIncome) :-
    elects_to_itemize(Taxpayer, Year),
    gross_income(Taxpayer, Year, GrossIncome),
    itemized_deductions_allowed(Taxpayer, Year, ItemizedDeductions),
    TaxableIncome is GrossIncome - ItemizedDeductions.

% (b) Individuals who do not itemize their deductions
taxable_income(Taxpayer, Year, TaxableIncome) :-
    \+ elects_to_itemize(Taxpayer, Year),
    adjusted_gross_income(Taxpayer, Year, AGI),
    standard_deduction(Taxpayer, Year, SD),
    personal_exemption_deduction(Taxpayer, Year, PED),
    TaxableIncome is max(0, AGI - SD - PED).

% (d) Itemized deductions (definition used in §68)
itemized_deductions_allowed(Taxpayer, Year, AllowedDeductions) :-
    itemized_deductions_otherwise_allowable(Taxpayer, Year, OtherwiseAllowable),
    limitation_on_itemized_deductions(Taxpayer, Year, Reduction),
    AllowedDeductions is OtherwiseAllowable - Reduction.

% (c) Standard deduction
standard_deduction(Taxpayer, Year, SD) :-
    \+ is_ineligible_for_standard_deduction(Taxpayer, Year),
    basic_standard_deduction(Taxpayer, Year, BSD),
    additional_standard_deduction(Taxpayer, Year, ASD),
    SD is BSD + ASD.
standard_deduction(Taxpayer, Year, 0) :-
    is_ineligible_for_standard_deduction(Taxpayer, Year).

% (c)(2) Basic standard deduction
basic_standard_deduction(Taxpayer, Year, BSD) :-
    is_dependent_of_another(Taxpayer, Year), !,
    basic_standard_deduction_for_dependent(Taxpayer, Year, BSD).
basic_standard_deduction(Taxpayer, Year, BSD) :-
    \+ is_dependent_of_another(Taxpayer, Year),
    basic_standard_deduction_for_non_dependent(Taxpayer, Year, BSD).

basic_standard_deduction_for_non_dependent(Taxpayer, Year, BSD) :-
    filing_status(Taxpayer, Year, married_filing_jointly),
    basic_sd_amount(any_other_case, Year, AmountC),
    BSD is 2 * AmountC.
basic_standard_deduction_for_non_dependent(Taxpayer, Year, BSD) :-
    filing_status(Taxpayer, Year, surviving_spouse),
    basic_sd_amount(any_other_case, Year, AmountC),
    BSD is 2 * AmountC.
basic_standard_deduction_for_non_dependent(Taxpayer, Year, BSD) :-
    filing_status(Taxpayer, Year, head_of_household),
    basic_sd_amount(head_of_household, Year, BSD).
basic_standard_deduction_for_non_dependent(Taxpayer, Year, BSD) :-
    (   filing_status(Taxpayer, Year, single)
    ;   filing_status(Taxpayer, Year, married_filing_separately)
    ),
    basic_sd_amount(any_other_case, Year, BSD).

% (c)(7) Special rules for taxable years 2018 through 2025
basic_sd_amount(head_of_household, Year, 18000) :- is_year_2018_to_2025(Year), !.
basic_sd_amount(any_other_case, Year, 12000) :- is_year_2018_to_2025(Year), !.
basic_sd_amount(head_of_household, _, 4400).
basic_sd_amount(any_other_case, _, 3000).

% (c)(5) Limitation on basic standard deduction in the case of certain dependents
basic_standard_deduction_for_dependent(Taxpayer, Year, BSD) :-
    earned_income(Taxpayer, Year, EarnedIncome),
    BSD is max(500, 250 + EarnedIncome).

% (c)(6) Certain individuals, etc., not eligible for standard deduction
is_ineligible_for_standard_deduction(Taxpayer, Year) :-
    filing_status(Taxpayer, Year, married_filing_separately),
    spouse(Taxpayer, Spouse),
    elects_to_itemize(Spouse, Year).
is_ineligible_for_standard_deduction(Taxpayer, _) :-
    is_nonresident_alien(Taxpayer).
is_ineligible_for_standard_deduction(Taxpayer, _) :-
    is_entity_type(Taxpayer, estate_or_trust).
is_ineligible_for_standard_deduction(Taxpayer, _) :-
    is_entity_type(Taxpayer, common_trust_fund).
is_ineligible_for_standard_deduction(Taxpayer, _) :-
    is_entity_type(Taxpayer, partnership).

% (c)(3) Additional standard deduction for aged and blind
additional_standard_deduction(Taxpayer, Year, ASD) :-
    findall(Amount, additional_amount(Taxpayer, Year, Amount), Amounts),
    sum_list(Amounts, ASD).

% (f) Aged or blind additional amounts
additional_amount(Taxpayer, Year, Amount) :-
    (   is_aged(Taxpayer, Year)
    ;   is_blind(Taxpayer, Year)
    ),
    asd_base_amount(Taxpayer, Year, Amount).
additional_amount(Taxpayer, Year, Amount) :-
    spouse(Taxpayer, Spouse),
    \+ files_joint_return(Taxpayer, Spouse, Year),
    additional_exemption_for_spouse_allowed(Taxpayer, Spouse, Year),
    (   is_aged(Spouse, Year)
    ;   is_blind_at_time_of_death(Spouse, Year)
    ),
    asd_base_amount(Taxpayer, Year, Amount).
additional_amount(Taxpayer, Year, Amount) :-
    spouse(Taxpayer, Spouse),
    files_joint_return(Taxpayer, Spouse, Year),
    (   is_aged(Spouse, Year)
    ;   is_blind_at_time_of_death(Spouse, Year)
    ),
    asd_base_amount(Taxpayer, Year, Amount).

asd_base_amount(Taxpayer, Year, 750) :-
    \+ is_married_at_close_of_year(Taxpayer, Year),
    \+ is_surviving_spouse(Taxpayer, Year), !.
asd_base_amount(_, _, 600).


% --- §151. Allowance of deductions for personal exemptions ---

% (a) Allowance of deductions
personal_exemption_deduction(Taxpayer, Year, Deduction) :-
    exemption_amount(Year, BaseAmount),
    ( BaseAmount = 0 -> Deduction = 0 ;
      (
        count_exemptions(Taxpayer, Year, Count),
        phased_out_exemption_amount(Taxpayer, Year, BaseAmount, PhasedOutAmount),
        Deduction is Count * PhasedOutAmount
      )
    ).

% (d)(5) Special rules for taxable years 2018 through 2025
exemption_amount(Year, 0) :- is_year_2018_to_2025(Year), !.
% (d)(1) In general
exemption_amount(_, 2000).

count_exemptions(Taxpayer, Year, Count) :-
    % (b) Taxpayer and spouse
    (   spouse(Taxpayer, Spouse),
        \+ files_joint_return(Taxpayer, Spouse, Year),
        additional_exemption_for_spouse_allowed(Taxpayer, Spouse, Year)
    ->  BaseCount = 2
    ;   BaseCount = 1
    ),
    % (c) Additional exemption for dependents
    findall(D, is_dependent(D, Taxpayer, Year), Dependents),
    length(Dependents, DependentCount),
    Count is BaseCount + DependentCount.

% (b) Taxpayer and spouse
additional_exemption_for_spouse_allowed(Taxpayer, Spouse, Year) :-
    \+ files_joint_return(Taxpayer, Spouse, Year),
    gross_income(Spouse, Year, 0),
    \+ is_dependent_of_another(Spouse, Year).

% (d)(2) Exemption amount disallowed in case of certain dependents
is_dependent_of_another(Individual, Year) :-
    is_dependent(Individual, _OtherTaxpayer, Year).

% (d)(3) Phaseout
phased_out_exemption_amount(Taxpayer, Year, BaseAmount, PhasedOutAmount) :-
    adjusted_gross_income(Taxpayer, Year, AGI),
    section_68_b_applicable_amount(Taxpayer, Year, Threshold),
    AGI > Threshold, !,
    ExcessAGI is AGI - Threshold,
    (   filing_status(Taxpayer, Year, married_filing_separately)
    ->  Divisor = 1250
    ;   Divisor = 2500
    ),
    ApplicablePercentageRaw is ceil(ExcessAGI / Divisor) * 0.02,
    ApplicablePercentage is min(1.0, ApplicablePercentageRaw),
    Reduction is BaseAmount * ApplicablePercentage,
    PhasedOutAmount is BaseAmount - Reduction.
phased_out_exemption_amount(_, _, BaseAmount, BaseAmount).


% --- §152. Dependent defined ---

% (a) In general
is_dependent(PotentialDependent, Taxpayer, Year) :-
    \+ dependent_is_ineligible(PotentialDependent, Taxpayer, Year),
    (   is_qualifying_child(PotentialDependent, Taxpayer, Year)
    ;   is_qualifying_relative(PotentialDependent, Taxpayer, Year)
    ).

% (b) Exceptions
dependent_is_ineligible(Individual, _, Year) :-
    % (1) Dependents ineligible
    is_dependent(Individual, _OtherTaxpayer, Year).
dependent_is_ineligible(Individual, _, Year) :-
    % (2) Married dependents
    spouse(Individual, Spouse),
    files_joint_return(Individual, Spouse, Year),
    \+ joint_return_for_refund_only(Individual, Spouse, Year).

% (c) Qualifying child
is_qualifying_child(Individual, Taxpayer, Year) :-
    % (1) In general
    qc_relationship_test(Individual, Taxpayer),
    qc_abode_test(Individual, Taxpayer, Year),
    qc_age_test(Individual, Taxpayer, Year),
    \+ qc_joint_return_test(Individual, Year).

% (c)(2) Relationship
qc_relationship_test(Individual, Taxpayer) :- child_of(Individual, Taxpayer).
qc_relationship_test(Individual, Taxpayer) :- descendant_of_child(Individual, Taxpayer).
qc_relationship_test(Individual, Taxpayer) :- sibling_of(Individual, Taxpayer).
qc_relationship_test(Individual, Taxpayer) :- step_sibling_of(Individual, Taxpayer).
qc_relationship_test(Individual, Taxpayer) :- descendant_of_sibling(Individual, Taxpayer).

% (c)(1)B Abode
qc_abode_test(Individual, Taxpayer, Year) :-
    principal_place_of_abode_for_more_than_half_year(Individual, Taxpayer, Year).

% (c)(3) Age requirements
qc_age_test(Individual, Taxpayer, Year) :-
    age(Individual, Year, AgeI),
    age(Taxpayer, Year, AgeT),
    AgeI < AgeT,
    AgeI < 25.

% (c)(1)E Joint return
qc_joint_return_test(Individual, Year) :-
    spouse(Individual, Spouse),
    files_joint_return(Individual, Spouse, Year),
    \+ joint_return_for_refund_only(Individual, Spouse, Year).

% (d) Qualifying relative
is_qualifying_relative(Individual, Taxpayer, Year) :-
    % (1) In general
    qr_relationship_test(Individual, Taxpayer, Year),
    qr_income_test(Individual, Year),
    qr_not_qualifying_child_test(Individual, Year).

% (d)(2) Relationship
qr_relationship_test(I, T, _) :- child_of(I, T).
qr_relationship_test(I, T, _) :- descendant_of_child(I, T).
qr_relationship_test(I, T, _) :- sibling_of(I, T).
qr_relationship_test(I, T, _) :- step_sibling_of(I, T).
qr_relationship_test(I, T, _) :- parent_of(I, T).
qr_relationship_test(I, T, _) :- ancestor_of_parent(I, T).
qr_relationship_test(I, T, _) :- step_parent_of(I, T).
qr_relationship_test(I, T, _) :- nephew_or_niece_of(I, T).
qr_relationship_test(I, T, _) :- uncle_or_aunt_of(I, T).
qr_relationship_test(I, T, _) :- in_law_of(I, T).
qr_relationship_test(I, T, Year) :- qr_household_member_test(I, T, Year).

% (d)(2)(H) Household member
qr_household_member_test(Individual, Taxpayer, Year) :-
    \+ was_spouse_during_year(Individual, Taxpayer, Year),
    principal_place_of_abode_for_entire_year(Individual, Taxpayer, Year),
    is_member_of_household(Individual, Taxpayer, Year).

% (d)(1)(B) Income test (simplified to no income)
qr_income_test(Individual, Year) :-
    gross_income(Individual, Year, 0).

% (d)(1)(D) Not a qualifying child test
qr_not_qualifying_child_test(Individual, Year) :-
    \+ is_qualifying_child(Individual, _, Year).


% --- §2. Definitions and special rules ---

% (a) Definition of surviving spouse
is_surviving_spouse(Taxpayer, Year) :-
    % (1) In general
    ss_spouse_death_test(Taxpayer, Year),
    ss_maintains_home_for_dependent_child(Taxpayer, Year),
    % (2) Limitations
    \+ ss_has_remarried(Taxpayer, Year),
    ss_could_have_filed_joint_return(Taxpayer, Year).

ss_spouse_death_test(Taxpayer, Year) :-
    spouse_death_year(Taxpayer, DeathYear),
    Year - DeathYear =< 2,
    Year - DeathYear >= 1.

ss_maintains_home_for_dependent_child(Taxpayer, Year) :-
    maintains_household(Taxpayer, Year),
    findnsols(1, Child, (
        is_dependent(Child, Taxpayer, Year),
        is_deduction_allowed_under_151(Taxpayer, Child, Year),
        (son_or_daughter(Child, Taxpayer); stepson_or_stepdaughter(Child, Taxpayer)),
        principal_place_of_abode_for_entire_year(Child, Taxpayer, Year)
    ), _).

ss_has_remarried(Taxpayer, Year) :-
    is_married_at_close_of_year(Taxpayer, Year).

ss_could_have_filed_joint_return(Taxpayer, Year) :-
    spouse_death_year(Taxpayer, DeathYear),
    spouse(Taxpayer, DeceasedSpouse),
    \+ is_nonresident_alien_at_any_time(Taxpayer, DeathYear),
    \+ is_nonresident_alien_at_any_time(DeceasedSpouse, DeathYear).

% (b) Definition of head of household
is_head_of_household(Taxpayer, Year) :-
    % (1) In general
    \+ is_married_at_close_of_year(Taxpayer, Year),
    \+ is_surviving_spouse(Taxpayer, Year),
    (   hoh_maintains_home_for_qualifying_person(Taxpayer, Year)
    ;   hoh_maintains_home_for_parent(Taxpayer, Year)
    ),
    % (3) Limitations
    \+ is_nonresident_alien_at_any_time(Taxpayer, Year).

hoh_maintains_home_for_qualifying_person(Taxpayer, Year) :-
    maintains_household(Taxpayer, Year),
    (   hoh_qualifying_child_test(Taxpayer, Year)
    ;   hoh_other_dependent_test(Taxpayer, Year)
    ).

hoh_qualifying_child_test(Taxpayer, Year) :-
    is_qualifying_child(Child, Taxpayer, Year),
    principal_place_of_abode_for_more_than_half_year(Child, Taxpayer, Year),
    \+ (
        is_married_at_close_of_year(Child, Year),
        is_not_dependent_by_152b2(Child, Taxpayer, Year)
    ).

is_not_dependent_by_152b2(Child, _, Year) :-
    spouse(Child, Spouse),
    files_joint_return(Child, Spouse, Year),
    \+ joint_return_for_refund_only(Child, Spouse, Year).

hoh_other_dependent_test(Taxpayer, Year) :-
    is_dependent(Dependent, Taxpayer, Year),
    \+ is_qualifying_child(Dependent, Taxpayer, Year),
    is_deduction_allowed_under_151(Taxpayer, Dependent, Year),
    principal_place_of_abode_for_more_than_half_year(Dependent, Taxpayer, Year),
    % (3)(B) Limitation
    \+ qr_household_member_test(Dependent, Taxpayer, Year).

hoh_maintains_home_for_parent(Taxpayer, Year) :-
    maintains_household_for_parent(Taxpayer, Year),
    parent_of(Parent, Taxpayer),
    is_dependent(Parent, Taxpayer, Year),
    is_deduction_allowed_under_151(Taxpayer, Parent, Year).

% (b)(2) Determination of status for HoH
is_not_married_at_close_of_year(Taxpayer, Year) :-
    is_legally_separated(Taxpayer, Year).
is_not_married_at_close_of_year(Taxpayer, Year) :-
    spouse(Taxpayer, Spouse),
    is_nonresident_alien_at_any_time(Spouse, Year).
is_not_married_at_close_of_year(Taxpayer, Year) :-
    \+ is_married_at_close_of_year(Taxpayer, Year).


% --- §68. Overall limitation on itemized deductions ---

% (f) Section not to apply
limitation_on_itemized_deductions(_, Year, 0) :-
    is_year_2018_to_2025(Year), !.
% (a) General rule
limitation_on_itemized_deductions(Taxpayer, Year, Reduction) :-
    adjusted_gross_income(Taxpayer, Year, AGI),
    section_68_b_applicable_amount(Taxpayer, Year, ApplicableAmount),
    AGI > ApplicableAmount, !,
    ExcessAGI is AGI - ApplicableAmount,
    Reduction1 is 0.03 * ExcessAGI,
    itemized_deductions_otherwise_allowable(Taxpayer, Year, OtherwiseAllowable),
    Reduction2 is 0.80 * OtherwiseAllowable,
    Reduction is min(Reduction1, Reduction2).
limitation_on_itemized_deductions(_, _, 0).

% (b) Applicable amount
section_68_b_applicable_amount(Taxpayer, Year, 300000) :-
    (   filing_status(Taxpayer, Year, married_filing_jointly)
    ;   filing_status(Taxpayer, Year, surviving_spouse)
    ), !.
section_68_b_applicable_amount(Taxpayer, Year, 275000) :-
    filing_status(Taxpayer, Year, head_of_household), !.
section_68_b_applicable_amount(Taxpayer, Year, 250000) :-
    filing_status(Taxpayer, Year, single), !.
section_68_b_applicable_amount(Taxpayer, Year, 150000) :-
    filing_status(Taxpayer, Year, married_filing_separately), !.


% --- §7703. Determination of marital status ---

% (a) General rule
is_married(Person1, Person2, Year) :-
    spouse(Person1, Person2),
    \+ is_considered_not_married(Person1, Year).

is_married_at_close_of_year(Person, Year) :-
    spouse(Person, Spouse),
    \+ (spouse_death_year(Spouse, Year), \+ is_married_at_time_of_death(Person, Spouse, Year)),
    \+ is_legally_separated(Person, Year).

is_married_at_time_of_death(Person, Spouse, Year) :-
    spouse_death_year(Spouse, Year),
    \+ is_legally_separated_before_death(Person, Spouse, Year).

is_considered_not_married(Person, Year) :-
    is_legally_separated(Person, Year).
is_considered_not_married(Person, Year) :-
    is_considered_not_married_living_apart(Person, Year).

% (b) Certain married individuals living apart
is_considered_not_married_living_apart(Taxpayer, Year) :-
    is_married_at_close_of_year(Taxpayer, Year),
    filing_status(Taxpayer, Year, married_filing_separately),
    maintains_household_for_child(Taxpayer, Year),
    furnishes_over_half_cost_of_household(Taxpayer, Year),
    spouse_not_in_household_last_6_months(Taxpayer, Year).

maintains_household_for_child(Taxpayer, Year) :-
    child_of(Child, Taxpayer),
    is_deduction_allowed_under_151(Taxpayer, Child, Year),
    principal_place_of_abode_for_more_than_half_year(Child, Taxpayer, Year).


% --- §3301 & §3306. FUTA Tax ---

% §3306(a) Employer
is_employer(Person, Year) :- is_general_employer(Person, Year).
is_employer(Person, Year) :- is_agricultural_employer(Person, Year).
is_employer(Person, Year) :- is_domestic_service_employer(Person, Year).

is_general_employer(Person, Year) :-
    paid_wages_for_general_employment(Person, Year, Amount), Amount >= 1500.
is_general_employer(Person, Year) :-
    employed_one_in_10_weeks(Person, Year, general).

is_agricultural_employer(Person, Year) :-
    paid_wages_for_agricultural_labor(Person, Year, Amount), Amount >= 20000.
is_agricultural_employer(Person, Year) :-
    employed_five_in_10_weeks(Person, Year, agricultural).

is_domestic_service_employer(Person, Year) :-
    paid_cash_wages_for_domestic_service(Person, Year, Amount), Amount >= 1000.

% §3306(b) Wages
total_futa_wages(Employer, Year, TotalWages) :-
    findall(Employee, employs(Employer, Employee, Year), Employees),
    maplist(futa_wages_per_employee(Employer, Year), Employees, WageList),
    sum_list(WageList, TotalWages).

futa_wages_per_employee(Employer, Year, Employee, EmployeeFutaWages) :-
    findall(Amount, futa_payment(Employer, Employee, Year, Amount), Payments),
    sum_list(Payments, TotalRemuneration),
    EmployeeFutaWages is min(TotalRemuneration, 7000).

futa_payment(Employer, Employee, Year, Amount) :-
    payment(Employer, Employee, Year, Amount, Type, Medium),
    is_futa_employment(Employee, Employer, Year, Type),
    is_futa_wage(Medium).

is_futa_wage(cash).
is_futa_wage(non_cash) :- \+ service_not_in_course_of_business, \+ agricultural_labor.

% §3306(c) Employment
is_futa_employment(Employee, Employer, Year, ServiceType) :-
    service_performed_by_employee(Employee, Employer, Year, ServiceType),
    \+ is_excepted_futa_service(Employee, Employer, Year, ServiceType).

is_excepted_futa_service(E, P, _, _) :- service_performed_for_family(E, P).
is_excepted_futa_service(E, P, Y, _) :- service_performed_by_child_under_21(E, P, Y).
is_excepted_futa_service(_, P, _, _) :- service_performed_for_government(P).
is_excepted_futa_service(_, P, _, _) :- service_performed_for_foreign_government(P).
is_excepted_futa_service(_, P, _, _) :- service_performed_for_international_org(P).
is_excepted_futa_service(E, _, _, _) :- service_performed_by_inmate(E).
is_excepted_futa_service(E, P, _, _) :- service_performed_by_student(E, P).
is_excepted_futa_service(E, P, _, _) :- service_performed_by_student_spouse(E, P).
is_excepted_futa_service(E, P, _, _) :- service_performed_by_patient(E, P).
is_excepted_futa_service(E, P, _, _) :- service_performed_by_student_nurse(E, P).
is_excepted_futa_service(_, _, _, agricultural) :- \+ is_covered_agricultural_labor.
is_excepted_futa_service(_, P, Y, domestic) :- \+ is_covered_domestic_service(P, Y).

service_performed_for_family(Employee, Employer) :- child_of(Employer, Employee).
service_performed_for_family(Employee, Employer) :- parent_of(Employer, Employee).
service_performed_for_family(Employee, Employer) :- spouse(Employee, Employer).
service_performed_by_child_under_21(Child, Parent, Year) :-
    child_of(Child, Parent), age(Child, Year, Age), Age < 21.

is_covered_domestic_service(Employer, Year) :-
    paid_cash_wages_for_domestic_service(Employer, Year, Amount), Amount >= 1000.


% --- Filing Status Determination ---

filing_status(Taxpayer, Year, married_filing_jointly) :-
    spouse(Taxpayer, Spouse),
    files_joint_return(Taxpayer, Spouse, Year).
filing_status(Taxpayer, Year, married_filing_separately) :-
    is_married_at_close_of_year(Taxpayer, Year),
    \+ filing_status(Taxpayer, Year, married_filing_jointly).
filing_status(Taxpayer, Year, surviving_spouse) :-
    is_surviving_spouse(Taxpayer, Year).
filing_status(Taxpayer, Year, head_of_household) :-
    \+ is_married_at_close_of_year(Taxpayer, Year),
    \+ is_surviving_spouse(Taxpayer, Year),
    is_head_of_household(Taxpayer, Year).
filing_status(Taxpayer, Year, single) :-
    \+ is_married_at_close_of_year(Taxpayer, Year),
    \+ is_surviving_spouse(Taxpayer, Year),
    \+ is_head_of_household(Taxpayer, Year).


% --- Kinship Helper Predicates ---

child_of(C, P) :- parent_of(C, P).
descendant_of(D, A) :- parent_of(D, A).
descendant_of(D, A) :- parent_of(D, P), descendant_of(P, A).
ancestor_of(A, D) :- descendant_of(D, A).
sibling_of(S1, S2) :- parent_of(S1, P), parent_of(S2, P), S1 \== S2.
step_parent_of(SP, C) :- spouse(SP, P), parent_of(C, P), \+ parent_of(C, SP).
step_child_of(C, SP) :- step_parent_of(SP, C).
step_sibling_of(S1, S2) :- parent_of(S1, P1), step_parent_of(P1, S2).
step_sibling_of(S1, S2) :- step_parent_of(S1, P2), parent_of(P2, S2).
descendant_of_child(D, T) :- child_of(C, T), descendant_of(D, C).
descendant_of_sibling(D, T) :- sibling_of(S, T), descendant_of(D, S).
nephew_or_niece_of(N, T) :- sibling_of(S, T), child_of(N, S).
uncle_or_aunt_of(U, T) :- parent_of(P, T), sibling_of(U, P).
in_law_of(I, T) :- spouse(S, T), parent_of(I, S). % father/mother-in-law
in_law_of(I, T) :- spouse(S, T), child_of(S, I).  % son/daughter-in-law
in_law_of(I, T) :- spouse(S, T), sibling_of(I, S). % brother/sister-in-law
in_law_of(I, T) :- sibling_of(B, T), spouse(I, B). % brother/sister-in-law
son_or_daughter(C, P) :- child_of(C, P).
stepson_or_stepdaughter(C, P) :- step_child_of(C, P).
ancestor_of_parent(A, T) :- parent_of(P, T), ancestor_of(A, P).


% --- Generic Helper Predicates ---

is_year_2018_to_2025(Year) :- Year > 2017, Year < 2026.

age(Person, Year, Age) :-
    date_of_birth(Person, date(BirthYear, _, _)),
    Age is Year - BirthYear.

maintains_household(Taxpayer, Year) :-
    cost_of_maintaining_household(Taxpayer, Year, Cost),
    Cost > 0.5 * total_household_cost(Taxpayer, Year).

is_deduction_allowed_under_151(Taxpayer, Dependent, Year) :-
    % Simplified: assumes deduction is allowed if they are a dependent.
    % A full implementation would check phaseouts etc.
    is_dependent(Dependent, Taxpayer, Year).

% --- Sample Data (for demonstration) ---

% People and relationships
person(john).
person(jane).
person(jim).
person(sue).
person(grandpa).
person(grandma).
person(bob).
person(mary).

date_of_birth(john, date(1980, 5, 10)).
date_of_birth(jane, date(1982, 3, 15)).
date_of_birth(jim, date(2010, 7, 20)).
date_of_birth(sue, date(2012, 9, 1)).
date_of_birth(grandpa, date(1950, 1, 1)).
date_of_birth(grandma, date(1952, 2, 2)).
date_of_birth(bob, date(1978, 1, 1)).
date_of_birth(mary, date(1979, 1, 1)).

spouse(john, jane).
spouse(jane, john).
spouse(grandpa, grandma).
spouse(grandma, grandpa).
spouse(bob, mary).
spouse(mary, bob).

parent_of(jim, john).
parent_of(jim, jane).
parent_of(sue, john).
parent_of(sue, jane).
parent_of(john, grandpa).
parent_of(john, grandma).

% Financial and filing data for a given year (e.g., 2024)
files_joint_return(john, jane, 2024).
elects_to_itemize(john, 2024) :- fail. % John and Jane take standard deduction
elects_to_itemize(jane, 2024) :- fail.

adjusted_gross_income(john, 2024, 150000).
adjusted_gross_income(jane, 2024, 0). % Not used in joint return
gross_income(john, 2024, 155000).
gross_income(jane, 2024, 0).
gross_income(jim, 2024, 0).
gross_income(sue, 2024, 0).
gross_income(grandpa, 2024, 0).

principal_place_of_abode_for_more_than_half_year(jim, john, 2024).
principal_place_of_abode_for_more_than_half_year(sue, john, 2024).

% Data for Head of Household example (Bob)
adjusted_gross_income(bob, 2024, 80000).
gross_income(bob, 2024, 82000).
elects_to_itemize(bob, 2024) :- fail.
parent_of(jim, bob). % Bob is Jim's father
principal_place_of_abode_for_more_than_half_year(jim, bob, 2024).
maintains_household(bob, 2024).
cost_of_maintaining_household(bob, 2024, 20000).
total_household_cost(bob, 2024, 30000).

% FUTA Data
employs(acme_corp, worker1, 2024).
employs(acme_corp, worker2, 2024).
payment(acme_corp, worker1, 2024, 10000, general, cash).
payment(acme_corp, worker2, 2024, 5000, general, cash).
paid_wages_for_general_employment(acme_corp, 2024, 15000).
service_performed_by_employee(worker1, acme_corp, 2024, general).
service_performed_by_employee(worker2, acme_corp, 2024, general).

% Data for dependent limitation on standard deduction
person(college_student).
date_of_birth(college_student, date(2003, 6, 1)).
parent_of(college_student, john).
is_dependent(college_student, john, 2024).
earned_income(college_student, 2024, 2000).
adjusted_gross_income(college_student, 2024, 2000).
elects_to_itemize(college_student, 2024) :- fail.
is_dependent_of_another(college_student, 2024).

% Data for surviving spouse example
person(widow).
person(deceased_spouse).
person(orphan_child).
spouse(widow, deceased_spouse).
spouse_death_year(widow, 2023).
parent_of(orphan_child, widow).
parent_of(orphan_child, deceased_spouse).
date_of_birth(orphan_child, date(2015, 1, 1)).
gross_income(orphan_child, 2024, 0).
maintains_household(widow, 2024).
cost_of_maintaining_household(widow, 2024, 20000).
total_household_cost(widow, 2024, 30000).
principal_place_of_abode_for_entire_year(orphan_child, widow, 2024).
adjusted_gross_income(widow, 2024, 70000).
elects_to_itemize(widow, 2024) :- fail.
is_nonresident_alien_at_any_time(_,_) :- fail. % Assume no one is a non-resident alien.