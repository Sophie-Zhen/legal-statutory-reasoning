:- module(section1,
          [ tax_imposed/4 % tax_imposed(FilingStatus, TaxableIncome, Year, Tax)
          ]).

:- use_module(helpers, [calculate_tax_from_brackets/3, round_to_nearest_dollar/2]).
:- use_module(knowledge_base, [tax_brackets/3]).
:- use_module(section2, [filing_status/4]).

% §1 Tax Imposed
% This is a dispatcher based on filing status.
tax_imposed(FilingStatus, TaxableIncome, Year, FinalTax) :-
    knowledge_base:tax_brackets(Year, FilingStatus, Brackets),
    calculate_tax_from_brackets(TaxableIncome, Brackets, RawTax),
    round_to_nearest_dollar(RawTax, FinalTax).
