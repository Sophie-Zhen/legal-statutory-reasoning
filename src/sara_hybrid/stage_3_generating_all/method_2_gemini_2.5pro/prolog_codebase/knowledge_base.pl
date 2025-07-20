:- module(knowledge_base,
    [
        tax_brackets/3,
        personal_exemption_amount/2,
        standard_deduction_basic/3,
        standard_deduction_dependent_limitation/3,
        standard_deduction_additional_amount/3,
        itemized_deduction_phaseout_threshold/3,
        itemized_deduction_phaseout_percentage/1,
        itemized_deduction_phaseout_max_reduction/1,
        phaseout_step_amount/2,
        futa_tax_rate/2,
        futa_wage_base/2,
        futa_employer_wage_threshold/3,
        futa_employer_employee_threshold/4,
        futa_domestic_service_threshold/2,
        futa_ag_labor_wage_threshold/2,
        futa_ag_labor_employee_threshold/4
    ]).

/**
 * knowledge_base.pl
 *
 * This module provides static data derived from the U.S. federal tax code.
 * Predicates are often parameterized by year to account for legislative changes.
 */

% §1 Tax Brackets (Pre-TCJA, e.g., for 2017 and prior)
tax_brackets(Year, married_filing_jointly, Brackets) :-
    Year < 2018,
    Brackets = [
        bracket(250000, 0.396, 75528.50),
        bracket(140000, 0.36,  35928.50),
        bracket(89150,  0.31,  20165.00),
        bracket(36900,  0.28,  5535.00),
        bracket(0,      0.15,  0)
    ].
tax_brackets(Year, head_of_household, Brackets) :-
    Year < 2018,
    Brackets = [
        bracket(250000, 0.396, 77485.00),
        bracket(127500, 0.36,  33385.00),
        bracket(76400,  0.31,  17544.00),
        bracket(29600,  0.28,  4440.00),
        bracket(0,      0.15,  0)
    ].
tax_brackets(Year, unmarried, Brackets) :-
    Year < 2018,
    Brackets = [
        bracket(250000, 0.396, 79772.00),
        bracket(115000, 0.36,  31172.00),
        bracket(53500,  0.31,  12107.00),
        bracket(22100,  0.28,  3315.00),
        bracket(0,      0.15,  0)
    ].
tax_brackets(Year, married_filing_separately, Brackets) :-
    Year < 2018,
    Brackets = [
        bracket(125000, 0.396, 37764.25),
        bracket(70000,  0.36,  17964.25),
        bracket(44575,  0.31,  10082.50),
        bracket(18450,  0.28,  2767.50),
        bracket(0,      0.15,  0)
    ].
tax_brackets(Year, Status, Brackets) :-
    Year >= 2018,
    tax_brackets(2017, Status, Brackets).

% §151(d) Personal Exemption Amount
personal_exemption_amount(Year, 0) :- Year > 2017, Year < 2026.
personal_exemption_amount(Year, 2000) :- \+ (Year > 2017, Year < 2026).

% §63(c) Basic Standard Deduction
standard_deduction_basic(Year, FilingStatus, Amount) :-
    Year > 2017, Year < 2026,
    ( (FilingStatus = married_filing_jointly; FilingStatus = surviving_spouse), Amount = 24000 ;
      FilingStatus = head_of_household, Amount = 18000 ;
      (FilingStatus = unmarried; FilingStatus = married_filing_separately), Amount = 12000
    ).
standard_deduction_basic(Year, FilingStatus, Amount) :-
    \+ (Year > 2017, Year < 2026),
    ( (FilingStatus = married_filing_jointly; FilingStatus = surviving_spouse), Amount = 6000 ;
      FilingStatus = head_of_household, Amount = 4400 ;
      (FilingStatus = unmarried; FilingStatus = married_filing_separately), Amount = 3000
    ).

% §63(c)(5) Limitation on Standard Deduction for Dependents
standard_deduction_dependent_limitation(Year, Floor, Base) :-
    ( Year < 2018 -> Floor = 500, Base = 250 ; Floor = 1100, Base = 350 ).

% §63(f) Additional Standard Deduction for Aged or Blind
standard_deduction_additional_amount(Year, TaxpayerStatus, Amount) :-
    member(TaxpayerStatus, [unmarried, head_of_household]),
    ( Year < 2018 -> Amount = 750 ; Amount = 1650 ).
standard_deduction_additional_amount(Year, TaxpayerStatus, Amount) :-
    member(TaxpayerStatus, [married_filing_jointly, married_filing_separately, surviving_spouse]),
    ( Year < 2018 -> Amount = 600 ; Amount = 1300 ).

% §68 Overall Limitation on Itemized Deductions
itemized_deduction_phaseout_threshold(Year, FilingStatus, Threshold) :-
    Year < 2018,
    ( (FilingStatus = married_filing_jointly; FilingStatus = surviving_spouse), Threshold = 300000 ;
      FilingStatus = head_of_household, Threshold = 275000 ;
      FilingStatus = unmarried, Threshold = 250000 ;
      FilingStatus = married_filing_separately, Threshold = 150000
    ).
itemized_deduction_phaseout_percentage(0.03).
itemized_deduction_phaseout_max_reduction(0.80).

% §151(d)(3) Exemption Phaseout
phaseout_step_amount(married_filing_separately, 1250).
phaseout_step_amount(FilingStatus, 2500) :- FilingStatus \= married_filing_separately.

% §3301 & §3306 FUTA Definitions
futa_tax_rate(_Year, 0.06).
futa_wage_base(_Year, 7000).
futa_employer_wage_threshold(_Year, general, 1500).
futa_employer_employee_threshold(_Year, general, 1, 10).
futa_domestic_service_threshold(_Year, 1000).
futa_ag_labor_wage_threshold(_Year, 20000).
futa_ag_labor_employee_threshold(_Year, 5, 10).
