:- module(section1,
          [
            s1_tax_imposed/4, % s1_tax_imposed(CaseID, TaxpayerID, TaxYear, TaxAmount) - gets TI from facts
            s1_tax_imposed/5, % s1_tax_imposed(CaseID, TaxpayerID, TaxYear, TaxableIncome, TaxAmount)
            s1_calculate_tax_from_ti/5 % Add this line
          ]).
:- use_module(section2, [s2_a_is_surviving_spouse/4, s2_b_is_head_of_household/4]).
:- use_module(section7703, [s7703_determination_of_marital_status/4]). % s7703_is_married/4 if more specific needed
:- use_module(helpers, [calculate_tax_from_brackets/3, round_to_nearest_dollar/2]).
:- use_module(tests, [fact/2]).
% s1_tax_imposed/4 - gets taxable income from facts and calls the helper
s1_tax_imposed(CaseID, TaxpayerID, TaxYear, TaxAmountRounded) :-
    fact(CaseID, taxable_income_for_s1(TaxpayerID, TaxYear, TaxableIncome)),
    s1_calculate_tax_from_ti(CaseID, TaxpayerID, TaxYear, TaxableIncome, TaxAmountRounded).
% s1_tax_imposed(CaseID, TaxpayerID, TaxYear, TaxableIncome, TaxAmount)
s1_tax_imposed(CaseID, TaxpayerID, TaxYear, TaxableIncome, TaxAmountRounded) :-
    s1_calculate_tax_from_ti(CaseID, TaxpayerID, TaxYear, TaxableIncome, TaxAmountRounded).
% s1_get_tax_brackets_for_status_year(CaseID, TaxpayerID, TaxYear, FilingStatus, TaxableIncome, Brackets)
% Determines which set of tax brackets to use based on filing status and year.
% For this exercise, only one set of rates (pre-TCJA like) is given for Sec 1. Assume these are for a specific year (e.g., 2017 or a generic pre-TCJA year).
% If year was a variable affecting rates, more clauses would be needed.
s1_get_tax_brackets_for_status_year(CaseID, TaxpayerID, TaxYear, FilingStatus, _TaxableIncome, Brackets) :-
    % (a) Married individuals filing joint returns and surviving spouses
    ( FilingStatus == joint_return ;
      ( FilingStatus == surviving_spouse_status_for_s1, % A specific status fact indicating SS for s1 rates
        s2_a_is_surviving_spouse(CaseID, TaxpayerID, TaxYear, true)
      )
    ), !,
    s1_a_brackets(Brackets).
s1_get_tax_brackets_for_status_year(CaseID, TaxpayerID, TaxYear, FilingStatus, _TaxableIncome, Brackets) :-
    % (b) Heads of households
    FilingStatus == head_of_household,
    s2_b_is_head_of_household(CaseID, TaxpayerID, TaxYear, true), !, % Verify they actually qualify as HoH
    s1_b_brackets(Brackets).
s1_get_tax_brackets_for_status_year(CaseID, TaxpayerID, TaxYear, FilingStatus, _TaxableIncome, Brackets) :-
    % (d) Married individuals filing separate returns
    FilingStatus == married_filing_separately,
    s7703_determination_of_marital_status(CaseID, TaxpayerID, TaxYear, married), % Must be married per 7703
     % No joint return made is implicit in MFS status.
    !,
    s1_d_brackets(Brackets).
s1_get_tax_brackets_for_status_year(CaseID, TaxpayerID, TaxYear, FilingStatus, _TaxableIncome, Brackets) :-
    % (c) Unmarried individuals (other than surviving spouses and heads of households) - e.g. Single
    ( FilingStatus == single ; FilingStatus == default_unmarried ), % Or some other status implying this category
    s7703_determination_of_marital_status(CaseID, TaxpayerID, TaxYear, MaritalStatus7703),
    (MaritalStatus7703 == not_married ; MaritalStatus7703 == considered_not_married_living_apart),
    \+ s2_a_is_surviving_spouse(CaseID, TaxpayerID, TaxYear, true),
    \+ s2_b_is_head_of_household(CaseID, TaxpayerID, TaxYear, true), !,
    s1_c_brackets(Brackets).
% Brackets definition: List of (BracketUpperLimit, MarginalRate, TaxOnIncomeUpToBracketStart, BracketStartIncome)
% Using 'inf' for the upper limit of the last bracket.
% These are based on the provided text for Section 1.
% s1_a_brackets (Married Filing Jointly / Surviving Spouse)
s1_a_brackets([
    (36900,  0.15, 0,        0),
    (89150,  0.28, 5535,     36900),
    (140000, 0.31, 20165,    89150),
    (250000, 0.36, 35928.50, 140000),
    (inf,    0.396,75528.50, 250000)
]).
% s1_b_brackets (Heads of Households)
s1_b_brackets([
    (29600,  0.15, 0,        0),
    (76400,  0.28, 4440,     29600),
    (127500, 0.31, 17544,    76400),
    (250000, 0.36, 33385,    127500),
    (inf,    0.396,77485,    250000)
]).
% s1_c_brackets (Unmarried Individuals - Single)
s1_c_brackets([
    (22100,  0.15, 0,        0),
    (53500,  0.28, 3315,     22100),
    (115000, 0.31, 12107,    53500),
    (250000, 0.36, 31172,    115000),
    (inf,    0.396,79772,    250000)
]).
% s1_d_brackets (Married Filing Separately)
s1_d_brackets([
    (18450,  0.15, 0,        0),
    (44575,  0.28, 2767.50,  18450),
    (70000,  0.31, 10082.50, 44575),
    (125000, 0.36, 17964.25, 70000),
    (inf,    0.396,37764.25, 125000)
]).
% Specific sub-section tax calculation predicates, useful for targeted test cases.
% s1_a_calculate_tax(TaxableIncome, TaxAmount)
s1_a_calculate_tax(TaxableIncome, TaxAmount) :-
    s1_a_brackets(Brackets),
    calculate_tax_from_brackets(TaxableIncome, Brackets, TaxAmount).
% s1_b_calculate_tax(TaxableIncome, TaxAmount)
s1_b_calculate_tax(TaxableIncome, TaxAmount) :-
    s1_b_brackets(Brackets),
    calculate_tax_from_brackets(TaxableIncome, Brackets, TaxAmount).
% s1_c_calculate_tax(TaxableIncome, TaxAmount)
s1_c_calculate_tax(TaxableIncome, TaxAmount) :-
    s1_c_brackets(Brackets),
    calculate_tax_from_brackets(TaxableIncome, Brackets, TaxAmount).
% s1_d_calculate_tax(TaxableIncome, TaxAmount)
s1_d_calculate_tax(TaxableIncome, TaxAmount) :-
    s1_d_brackets(Brackets),
    calculate_tax_from_brackets(TaxableIncome, Brackets, TaxAmount).
% Predicates for specific bracket calculations if needed by very granular tests
% Example: s1_d_iv_tax_calculation(TaxableIncome, TaxAmount)
% Taxable income over $70,000 but not over $125,000
% Tax = $17,964.25, plus 36% of the excess over $70,000
s1_d_iv_tax_calculation(TaxableIncome, TaxAmount) :-
    TaxableIncome > 70000, TaxableIncome =< 125000,
    TaxAmount is 17964.25 + 0.36 * (TaxableIncome - 70000).
s1_c_i_tax_calculation(TaxableIncome, TaxAmount) :-
    TaxableIncome > 0, TaxableIncome =< 22100,
    TaxAmount is 0.15 * TaxableIncome.
s1_b_iii_tax_calculation(TaxableIncome, TaxAmount) :-
    TaxableIncome > 76400, TaxableIncome =< 127500,
    TaxAmount is 17544 + 0.31 * (TaxableIncome - 76400).
s1_a_iii_tax_calculation(TaxableIncome, TaxAmount) :- % Name from case: s1_a_1_iii_neg
    TaxableIncome > 89150, TaxableIncome =< 140000,
    TaxAmount is 20165 + 0.31 * (TaxableIncome - 89150).
s1_c_iv_tax_calculation(TaxableIncome, TaxAmount) :-
    TaxableIncome > 115000, TaxableIncome =< 250000,
    TaxAmount is 31172 + 0.36 * (TaxableIncome - 115000).
% For s1_a_1_pos, it's just s1_a_calculate_tax.
% The case seems to imply the first bracket of s1(a).
s1_a_i_tax_calculation(TaxableIncome, TaxAmount) :-
    TaxableIncome > 0, TaxableIncome =< 36900,
    TaxAmount is 0.15 * TaxableIncome.
% NEW PREDICATE
% s1_calculate_tax_from_ti(CaseID, TaxpayerID, TaxYear, TaxableIncome, FinalTax)
% Calculates tax given an explicit TaxableIncome value.
s1_calculate_tax_from_ti(CaseID, TaxpayerID, TaxYear, TaxableIncome, TaxAmountRounded) :-
    fact(CaseID, filing_status(TaxpayerID, TaxYear, FilingStatus)),
    (TaxableIncome > 0 ->
        s1_get_tax_brackets_for_status_year(CaseID, TaxpayerID, TaxYear, FilingStatus, TaxableIncome, Brackets),
        calculate_tax_from_brackets(TaxableIncome, Brackets, RawTaxAmount),
        round_to_nearest_dollar(RawTaxAmount, TaxAmountRounded)
    ; % If TI is 0 or less, tax is 0.
        TaxAmountRounded = 0
    ).