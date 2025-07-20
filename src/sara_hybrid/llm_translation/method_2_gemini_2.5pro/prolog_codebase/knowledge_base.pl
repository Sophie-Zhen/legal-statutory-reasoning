:- module(knowledge_base,
          [ tax_brackets/3,              % tax_brackets(Year, FilingStatus, Brackets)
            basic_standard_deduction_amount/3, % basic_standard_deduction_amount(Year, FilingStatus, Amount)
            additional_deduction_aged_blind/3, % additional_deduction_aged_blind(Year, FilingStatus, Amount)
            dependent_deduction_limitation/3,  % dependent_deduction_limitation(Year, Param, Value)
            exemption_amount/2,                % exemption_amount(Year, Amount)
            phaseout_threshold/3,              % phaseout_threshold(Year, FilingStatus, Threshold)
            phaseout_step/3,                   % phaseout_step(Year, FilingStatus, Step)
            futa_wage_base/2,                  % futa_wage_base(Year, Base)
            futa_tax_rate/2,                   % futa_tax_rate(Year, Rate)
            futa_employer_threshold/3          % futa_employer_threshold(Year, Type, Value)
          ]).

:- use_module(helpers, [tcja_active_for_tax_year/1]).

% §1 Tax Brackets. Format: [bracket(UpperLimit, Rate, BaseTaxAtLowerLimit)]
% Using data for 2017 as representative for pre-TCJA years.
tax_brackets(Year, married_filing_jointly, [bracket(36900, 0.15, 0), bracket(89150, 0.28, 5535), bracket(140000, 0.31, 20165), bracket(250000, 0.36, 35928.50), bracket(inf, 0.396, 75528.50)]) :- \+ tcja_active_for_tax_year(Year).
tax_brackets(Year, surviving_spouse, Brackets) :- \+ tcja_active_for_tax_year(Year), tax_brackets(Year, married_filing_jointly, Brackets).
tax_brackets(Year, head_of_household, [bracket(29600, 0.15, 0), bracket(76400, 0.28, 4440), bracket(127500, 0.31, 17544), bracket(250000, 0.36, 33385), bracket(inf, 0.396, 77485)]) :- \+ tcja_active_for_tax_year(Year).
tax_brackets(Year, single, [bracket(22100, 0.15, 0), bracket(53500, 0.28, 3315), bracket(115000, 0.31, 12107), bracket(250000, 0.36, 31172), bracket(inf, 0.396, 79772)]) :- \+ tcja_active_for_tax_year(Year).
tax_brackets(Year, married_filing_separately, [bracket(18450, 0.15, 0), bracket(44575, 0.28, 2767.50), bracket(70000, 0.31, 10082.50), bracket(125000, 0.36, 17964.25), bracket(inf, 0.396, 37764.25)]) :- \+ tcja_active_for_tax_year(Year).

% Using data for 2019 as representative for TCJA years.
tax_brackets(Year, married_filing_jointly, [bracket(19400, 0.10, 0), bracket(78950, 0.12, 1940), bracket(168400, 0.22, 9086), bracket(321450, 0.24, 28765), bracket(408200, 0.32, 65497), bracket(612350, 0.35, 93041), bracket(inf, 0.37, 164709.25)]) :- tcja_active_for_tax_year(Year).
tax_brackets(Year, surviving_spouse, Brackets) :- tcja_active_for_tax_year(Year), tax_brackets(Year, married_filing_jointly, Brackets).
tax_brackets(Year, head_of_household, [bracket(13850, 0.10, 0), bracket(52850, 0.12, 1385), bracket(84200, 0.22, 6065), bracket(160700, 0.24, 12962), bracket(204100, 0.32, 31322), bracket(510300, 0.35, 45210), bracket(inf, 0.37, 152380)]) :- tcja_active_for_tax_year(Year).
tax_brackets(Year, single, [bracket(9700, 0.10, 0), bracket(39475, 0.12, 970), bracket(84200, 0.22, 4543), bracket(160725, 0.24, 14382.50), bracket(204100, 0.32, 32748.50), bracket(510300, 0.35, 46528.50), bracket(inf, 0.37, 153798.50)]) :- tcja_active_for_tax_year(Year).
tax_brackets(Year, married_filing_separately, [bracket(9700, 0.10, 0), bracket(39475, 0.12, 970), bracket(84200, 0.22, 4543), bracket(160725, 0.24, 14382.50), bracket(306175, 0.35, 46528.50), bracket(inf, 0.37, 82354.75)]) :- tcja_active_for_tax_year(Year).


% §63(c)(2) Basic Standard Deduction Amount
basic_standard_deduction_amount(Year, married_filing_jointly, 6000) :- \+ tcja_active_for_tax_year(Year), basic_standard_deduction_amount(Year, single, SingleAmount), C is 2 * SingleAmount. % §63(c)(2)(A) refers to (C)
basic_standard_deduction_amount(Year, surviving_spouse, Amount) :- \+ tcja_active_for_tax_year(Year), basic_standard_deduction_amount(Year, married_filing_jointly, Amount).
basic_standard_deduction_amount(_Year, head_of_household, 4400) :- \+ tcja_active_for_tax_year(_Year).
basic_standard_deduction_amount(_Year, single, 3000) :- \+ tcja_active_for_tax_year(_Year).
basic_standard_deduction_amount(_Year, married_filing_separately, 3000) :- \+ tcja_active_for_tax_year(_Year).

% §63(c)(7) TCJA Basic Standard Deduction Amount
basic_standard_deduction_amount(Year, married_filing_jointly, Amount) :- tcja_active_for_tax_year(Year), basic_standard_deduction_amount(Year, single, SingleAmount), Amount is 2 * SingleAmount.
basic_standard_deduction_amount(Year, surviving_spouse, Amount) :- tcja_active_for_tax_year(Year), basic_standard_deduction_amount(Year, married_filing_jointly, Amount).
basic_standard_deduction_amount(_Year, head_of_household, 18000) :- tcja_active_for_tax_year(_Year).
basic_standard_deduction_amount(_Year, single, 12000) :- tcja_active_for_tax_year(_Year).
basic_standard_deduction_amount(_Year, married_filing_separately, 12000) :- tcja_active_for_tax_year(_Year).

% §63(c)(5) Limitation on basic standard deduction for dependents
dependent_deduction_limitation(_Year, floor, 500).
dependent_deduction_limitation(_Year, earned_income_add, 250).

% §63(f) Additional standard deduction for aged and blind
additional_deduction_aged_blind(_Year, FilingStatus, 750) :- member(FilingStatus, [single, head_of_household]).
additional_deduction_aged_blind(_Year, FilingStatus, 600) :- member(FilingStatus, [married_filing_jointly, married_filing_separately, surviving_spouse]).

% §151(d) Exemption Amount
exemption_amount(Year, 0) :- tcja_active_for_tax_year(Year).
exemption_amount(Year, 2000) :- \+ tcja_active_for_tax_year(Year).

% §68(b) Phaseout Thresholds for Itemized Deductions (Applicable Amount) - Pre-TCJA
phaseout_threshold(Year, married_filing_jointly, 300000) :- \+ tcja_active_for_tax_year(Year).
phaseout_threshold(Year, surviving_spouse, 300000) :- \+ tcja_active_for_tax_year(Year).
phaseout_threshold(Year, head_of_household, 275000) :- \+ tcja_active_for_tax_year(Year).
phaseout_threshold(Year, single, 250000) :- \+ tcja_active_for_tax_year(Year).
phaseout_threshold(Year, married_filing_separately, 150000) :- \+ tcja_active_for_tax_year(Year).

% §151(d)(3) Phaseout Step for Personal Exemptions - Pre-TCJA
phaseout_step(_Year, married_filing_separately, 1250).
phaseout_step(_Year, _, 2500).

% §3301, §3306 FUTA constants
futa_tax_rate(_Year, 0.06).
futa_wage_base(_Year, 7000).
futa_employer_threshold(_Year, general_wages, 1500).
futa_employer_threshold(_Year, domestic_wages, 1000).
futa_employer_threshold(_Year, agricultural_wages, 20000).
futa_employer_threshold(_Year, general_employees, 1).
futa_employer_threshold(_Year, agricultural_employees, 5).
futa_employer_threshold(_Year, weeks, 10).
