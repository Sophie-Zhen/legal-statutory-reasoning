:- module(helpers,
          [ total_tax_liability/3,
            calculate_tax_from_brackets/4,
            get_age_at_year_end/4,
            round_to_nearest_dollar/2,
            tcja_active_general/1
          ]).

/**
 * helpers.pl
 *
 * This module provides general-purpose helper predicates for logic and
 * arithmetic operations required across different statute modules. It also
 * contains the top-level predicate for orchestrating a full tax liability
 * calculation.
 *
 * It implements core functionalities like age calculation, rounding,
 * determining TCJA applicability, and a generic tax bracket calculation
 * function as requested by the generation plan.
 */

:- use_module(knowledge_base).

% total_tax_liability(+Taxpayer, +Year, -TotalTax)
%
% This is the main orchestrator for calculating an individual's total tax.
% It determines filing status, calculates taxable income, applies the correct
% tax rates, and provides a final, rounded tax amount.
% This predicate relies on other statute modules to provide their specific outputs.
% The module-prefixed calls (e.g., statute_2:...) ensure that the system
% can compile this file before the statute-specific files are generated.
% The flow is:
% 1. Determine filing status (§2).
% 2. Determine taxable income (§63), which itself depends on filing status.
% 3. Calculate the raw tax using the generic bracket calculator.
% 4. Round the final result.
total_tax_liability(Taxpayer, Year, TotalTax) :-
    statute_2:filing_status(Taxpayer, Year, FilingStatus),
    statute_63:taxable_income(Taxpayer, Year, FilingStatus, TaxableIncome),
    calculate_tax_from_brackets(FilingStatus, TaxableIncome, Year, UnroundedTax),
    round_to_nearest_dollar(UnroundedTax, TotalTax).


% calculate_tax_from_brackets(+FilingStatus, +TaxableIncome, +Year, -Tax)
%
% Calculates the tax for a given taxable income based on the bracket
% structures defined in the knowledge base. This logic is derived from §1.
% NOTE: Implemented as arity 4 as FilingStatus, TaxableIncome, and Year are
% all logically required to determine the correct tax bracket and rate.
calculate_tax_from_brackets(FilingStatus, TaxableIncome, Year, Tax) :-
    TaxableIncome > 0,
    get_year_period(Year, Period),
    % Find the correct tax bracket from the knowledge base
    knowledge_base:tax_rate_table(Period, FilingStatus, LowerBound, UpperBound, (BaseTax, Rate)),
    TaxableIncome > LowerBound,
    ( UpperBound == inf ; TaxableIncome =< UpperBound ),
    !, % We found the right bracket, commit.
    Excess is TaxableIncome - LowerBound,
    Tax is BaseTax + (Excess * Rate).
calculate_tax_from_brackets(_FilingStatus, TaxableIncome, _Year, 0) :-
    TaxableIncome =< 0.


% get_age_at_year_end(+BirthYear, +BirthMonth, +TaxYear, -Age)
%
% Calculates the age of an individual as of the end of the given TaxYear.
% Per the prompt's arity requirement, this predicate takes four arguments.
% For simplicity and based on statute text like "attained age 65 before the
% close of his taxable year", a simple year subtraction is sufficient. The
% birth month is included for signature compliance but not used in the calculation.
get_age_at_year_end(BirthYear, _BirthMonth, TaxYear, Age) :-
    Age is TaxYear - BirthYear.


% round_to_nearest_dollar(+Value, -Rounded)
%
% Rounds a numeric value to the nearest integer (dollar).
round_to_nearest_dollar(Value, Rounded) :-
    Rounded is round(Value).


% tcja_active_general(+Year)
%
% Succeeds if the given Year falls within the general active period of the
% Tax Cuts and Jobs Act (TCJA) provisions described in the statutes
% (i.e., for taxable years 2018 through 2025).
tcja_active_general(Year) :-
    Year >= 2018,
    Year =< 2025.


% get_year_period(+Year, -Period)
%
% Internal helper to determine the symbolic time period for a given year,
% used to select the correct set of rules/constants from the knowledge base.
get_year_period(Year, post_2017) :-
    tcja_active_general(Year), !.
get_year_period(_Year, pre_2018).