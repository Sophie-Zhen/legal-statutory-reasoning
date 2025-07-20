% §63. Taxable income defined

% (a) In general
% Except as provided in subsection (b), for purposes of this subtitle, the term "taxable income" means gross income minus the deductions allowed by this chapter (other than the standard deduction).
s63_a_taxable_income(Event, TaxableIncome) :-
    gross_income(Event, GrossIncome),
    deductions_allowed(Event, Deductions),
    \+ standard_deduction(Event, _),
    TaxableIncome is GrossIncome - Deductions.

% (b) Individuals who do not itemize their deductions
% In the case of an individual who does not elect to itemize his deductions for the taxable year, for purposes of this subtitle, the term "taxable income" means adjusted gross income, minus-
s63_b_taxable_income(Event, TaxableIncome) :-
    \+ itemized_deductions_elected(Event),
    adjusted_gross_income(Event, AdjustedGrossIncome),
    standard_deduction(Event, StandardDeduction),
    personal_exemptions_deduction(Event, PersonalExemptions),
    TaxableIncome is AdjustedGrossIncome - StandardDeduction - PersonalExemptions.

% (c) Standard deduction

% (1) In general
% Except as otherwise provided in this subsection, the term "standard deduction" means the sum of-
s63_c_1_standard_deduction(Event, StandardDeduction) :-
    basic_standard_deduction(Event, BasicStandardDeduction),
    additional_standard_deduction(Event, AdditionalStandardDeduction),
    StandardDeduction is BasicStandardDeduction + AdditionalStandardDeduction.

% (2) Basic standard deduction
% For purposes of paragraph (1), the basic standard deduction is-
s63_c_2_basic_standard_deduction(Event, BasicStandardDeduction) :-
    (   joint_return(Event)
    ;   surviving_spouse(Event)
    ),
    dollar_amount(Event, DollarAmount),
    BasicStandardDeduction is 2 * DollarAmount.

s63_c_2_basic_standard_deduction(Event, 4400) :-
    head_of_household(Event).

s63_c_2_basic_standard_deduction(Event, 3000) :-
    \+ joint_return(Event),
    \+ surviving_spouse(Event),
    \+ head_of_household(Event).

% (3) Additional standard deduction for aged and blind
% For purposes of paragraph (1), the additional standard deduction is the sum of each additional amount to which the taxpayer is entitled under subsection (f).
s63_c_3_additional_standard_deduction(Event, AdditionalStandardDeduction) :-
    findall(Amount, s63_f_additional_amount(Event, Amount), Amounts),
    sum_list(Amounts, AdditionalStandardDeduction).

% (5) Limitation on basic standard deduction in the case of certain dependents
% In the case of an individual with respect to whom a deduction under section 151 is allowable to another taxpayer for a taxable year beginning in the calendar year in which the individual's taxable year begins, the basic standard deduction applicable to such individual for such individual's taxable year shall not exceed the greater of-
s63_c_5_basic_standard_deduction_limit(Event, BasicStandardDeduction) :-
    deduction_allowed_to_another(Event),
    earned_income(Event, EarnedIncome),
    BasicStandardDeduction is max(500, 250 + EarnedIncome).

% (6) Certain individuals, etc., not eligible for standard deduction
% In the case of-
s63_c_6_standard_deduction_zero(Event) :-
    (   married_filing_separately(Event),
        spouse_itemizes_deductions(Event)
    ;   nonresident_alien(Event)
    ;   estate_or_trust(Event)
    ),
    standard_deduction(Event, 0).

% (7) Special rules for taxable years 2018 through 2025
% In the case of a taxable year beginning after December 31, 2017, and before January 1, 2026-
s63_c_7_special_rules(Event, BasicStandardDeduction) :-
    taxable_year(Event, Year),
    Year > 2017,
    Year < 2026,
    (   head_of_household(Event),
        BasicStandardDeduction = 18000
    ;   \+ head_of_household(Event),
        BasicStandardDeduction = 12000
    ).

% (d) Itemized deductions
% For purposes of this subtitle, the term "itemized deductions" means the deductions allowable under this chapter other than-
s63_d_itemized_deductions(Event, ItemizedDeductions) :-
    deductions_allowed(Event, Deductions),
    deductions_for_adjusted_gross_income(Event, AGIDeductions),
    personal_exemptions_deduction(Event, PersonalExemptions),
    ItemizedDeductions is Deductions - AGIDeductions - PersonalExemptions.

% (f) Aged or blind additional amounts

% (1) Additional amounts for the aged
% The taxpayer shall be entitled to an additional amount of $600-
s63_f_1_additional_amount_aged(Event, 600) :-
    taxpayer_aged_65_or_older(Event).

s63_f_1_additional_amount_aged(Event, 600) :-
    spouse_aged_65_or_older(Event),
    additional_exemption_for_spouse(Event).

% (2) Additional amount for blind
% The taxpayer shall be entitled to an additional amount of $600-
s63_f_2_additional_amount_blind(Event, 600) :-
    taxpayer_blind(Event).

s63_f_2_additional_amount_blind(Event, 600) :-
    spouse_blind(Event),
    additional_exemption_for_spouse(Event).

% (3) Higher amount for certain unmarried individuals
% In the case of an individual who is not married and is not a surviving spouse, paragraphs (1) and (2) shall be applied by substituting "$750" for "$600".
s63_f_3_higher_amount_unmarried(Event, 750) :-
    \+ married(Event),
    \+ surviving_spouse(Event).

% (g) Marital status
% For purposes of this section, marital status shall be determined under section 7703.
s63_g_marital_status(Event, Status) :-
    marital_status(Event, Status).