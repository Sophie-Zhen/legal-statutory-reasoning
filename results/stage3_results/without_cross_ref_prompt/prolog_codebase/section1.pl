:- module(section1,
          [ tax_liability/4,
            tax_imposed_by_bracket/5
          ]).

:- use_module(knowledge_base, [tax_bracket/7]).
:- use_module(section63, [taxable_income/4]).
:- use_module(section2, [filing_status/4]).
:- use_module(helpers, [calculate_tax_from_brackets/3, get_tax_brackets_for_status/4, round_to_nearest_dollar/2]).

:- multifile fact/2.

/*
    §1. Tax imposed
    This module calculates the final tax liability based on taxable income and filing status.
*/

% tax_liability(CaseID, Taxpayer, Year, Tax)
% This is the primary predicate for calculating the final tax owed.
tax_liability(CaseID, Taxpayer, Year, FinalTax) :-
    taxable_income(CaseID, Taxpayer, Year, TI),
    filing_status(CaseID, Taxpayer, Year, FilingStatus),
    get_tax_brackets_for_status(Year, FilingStatus, Brackets),
    calculate_tax_from_brackets(TI, Brackets, RawTax),
    round_to_nearest_dollar(RawTax, FinalTax).

% tax_imposed_by_bracket(CaseID, Taxpayer, Year, BracketID, ExpectedTax)
% This predicate is specifically for testing if a given income falls into a specific bracket and yields a specific tax amount.
% It's used for the contradiction/entailment cases focused on a single tax bracket calculation.
tax_imposed_by_bracket(CaseID, _Taxpayer, Year, BracketID, ExpectedTax) :-
    fact(CaseID, taxable_income(TI)),
    atom_string(BracketID, BracketIDStr),
    tax_bracket(Year, _FilingStatus, Min, Max, Base, Rate, BracketIDStr),
    (Max == inf -> TI > Min ; TI > Min, TI =< Max),
    CalculatedTax is Base + (TI - Min) * Rate,
    round_to_nearest_dollar(CalculatedTax, RoundedTax),
    RoundedTax =:= ExpectedTax.
