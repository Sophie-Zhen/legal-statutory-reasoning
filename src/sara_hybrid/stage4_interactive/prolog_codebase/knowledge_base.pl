:- module(knowledge_base,
          [ tax_rate_table/5,
            exemption_amount/2,
            applicable_amount_phaseout/2,
            phaseout_percentage_rate/3,
            standard_deduction_amount/3,
            basic_standard_deduction_limitation/2,
            additional_standard_deduction_amount/2,
            overall_limitation_applicable_amount/3,
            futa_wage_base/2,
            employer_wage_threshold/2,
            employer_domestic_service_wage_threshold/2,
            employer_agricultural_wage_threshold/2,
            employment_domestic_service_wage_threshold/2,
            employment_agricultural_wage_threshold/2
          ]).

/**
 * knowledge_base.pl
 *
 * This module provides static knowledge derived from the tax code. It includes
 * non-inflation-adjusted dollar amounts, rates, and other constants that are
 * explicitly stated in the statutes. This centralizes constants for easy
 * maintenance and clarity.
 */

% Source: §1 - Tax imposed (Pre-TCJA rates, applicable to relevant cases)
% tax_rate_table(YearPeriod, FilingStatus, LowerBound, UpperBound, (BaseTax, Rate))
% Note: 'inf' represents infinity for the highest bracket's upper bound.

% §1(a) Married individuals filing joint returns and surviving spouses
tax_rate_table(pre_2018, married_filing_jointly, 0, 36900, (0, 0.15)).
tax_rate_table(pre_2018, married_filing_jointly, 36900, 89150, (5535.0, 0.28)).
tax_rate_table(pre_2018, married_filing_jointly, 89150, 140000, (20165.0, 0.31)).
tax_rate_table(pre_2018, married_filing_jointly, 140000, 250000, (35928.50, 0.36)).
tax_rate_table(pre_2018, married_filing_jointly, 250000, inf, (75528.50, 0.396)).

tax_rate_table(pre_2018, surviving_spouse, 0, 36900, (0, 0.15)).
tax_rate_table(pre_2018, surviving_spouse, 36900, 89150, (5535.0, 0.28)).
tax_rate_table(pre_2018, surviving_spouse, 89150, 140000, (20165.0, 0.31)).
tax_rate_table(pre_2018, surviving_spouse, 140000, 250000, (35928.50, 0.36)).
tax_rate_table(pre_2018, surviving_spouse, 250000, inf, (75528.50, 0.396)).

% §1(b) Heads of households
tax_rate_table(pre_2018, head_of_household, 0, 29600, (0, 0.15)).
tax_rate_table(pre_2018, head_of_household, 29600, 76400, (4440.0, 0.28)).
tax_rate_table(pre_2018, head_of_household, 76400, 127500, (17544.0, 0.31)).
tax_rate_table(pre_2018, head_of_household, 127500, 250000, (33385.0, 0.36)).
tax_rate_table(pre_2018, head_of_household, 250000, inf, (77485.0, 0.396)).

% §1(c) Unmarried individuals
tax_rate_table(pre_2018, unmarried, 0, 22100, (0, 0.15)).
tax_rate_table(pre_2018, unmarried, 22100, 53500, (3315.0, 0.28)).
tax_rate_table(pre_2018, unmarried, 53500, 115000, (12107.0, 0.31)).
tax_rate_table(pre_2018, unmarried, 115000, 250000, (31172.0, 0.36)).
tax_rate_table(pre_2018, unmarried, 250000, inf, (79772.0, 0.396)).

% §1(d) Married individuals filing separate returns
tax_rate_table(pre_2018, married_filing_separately, 0, 18450, (0, 0.15)).
tax_rate_table(pre_2018, married_filing_separately, 18450, 44575, (2767.50, 0.28)).
tax_rate_table(pre_2018, married_filing_separately, 44575, 70000, (10082.50, 0.31)).
tax_rate_table(pre_2018, married_filing_separately, 70000, 125000, (17964.25, 0.36)).
tax_rate_table(pre_2018, married_filing_separately, 125000, inf, (37764.25, 0.396)).

% Source: §151(d) Exemption amount
exemption_amount(default, 2000).
exemption_amount(year_2018_2025, 0).

% Source: §151(d)(3) Phaseout & §68(b) Applicable amount
applicable_amount_phaseout(joint_return, 300000).
applicable_amount_phaseout(surviving_spouse, 300000).
applicable_amount_phaseout(head_of_household, 275000).
applicable_amount_phaseout(unmarried, 250000).
applicable_amount_phaseout(married_filing_separately, 150000).

% Source: §151(d)(3)(B) Applicable percentage
phaseout_percentage_rate(married_filing_separately, 1250, 0.02).
phaseout_percentage_rate(other, 2500, 0.02).

% Source: §63(c) Standard deduction
standard_deduction_amount(pre_2018, joint_return, 6000).
standard_deduction_amount(pre_2018, surviving_spouse, 6000).
standard_d_amount(pre_2018, head_of_household, 4400).
standard_deduction_amount(pre_2018, other, 3000).

% Source: §63(c)(7) Special rules for taxable years 2018 through 2025
standard_deduction_amount(post_2017, joint_return, 24000).
standard_deduction_amount(post_2017, surviving_spouse, 24000).
standard_deduction_amount(post_2017, head_of_household, 18000).
standard_deduction_amount(post_2017, other, 12000).

% Source: §63(c)(5) Limitation on basic standard deduction for dependents
basic_standard_deduction_limitation(base, 500).
basic_standard_deduction_limitation(earned_income_add, 250).

% Source: §63(f) Aged or blind additional amounts
additional_standard_deduction_amount(default, 600).
additional_standard_deduction_amount(unmarried_not_surviving_spouse, 750).

% Source: §68(b) Applicable amount for overall limitation on itemized deductions
overall_limitation_applicable_amount(pre_2018, joint_return, 300000).
overall_limitation_applicable_amount(pre_2018, surviving_spouse, 300000).
overall_limitation_applicable_amount(pre_2018, head_of_household, 275000).
overall_limitation_applicable_amount(pre_2018, unmarried, 250000).
overall_limitation_applicable_amount(pre_2018, married_filing_separately, 150000).

% Source: §3306(b)(1) FUTA wage base
futa_wage_base(default, 7000).

% Source: §3306(a) Employer definition wage thresholds
employer_wage_threshold(general, 1500).
employer_domestic_service_wage_threshold(default, 1000).
employer_agricultural_wage_threshold(default, 20000).

% Source: §3306(c) Employment definition wage thresholds
employment_domestic_service_wage_threshold(default, 1000).
employment_agricultural_wage_threshold(default, 20000).