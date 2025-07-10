:- module(section3301,
          [ futa_tax/4 % futa_tax(Payer, Year, CaseID, Tax)
          ]).

:- use_module(section3306).
:- use_module(knowledge_base, [futa_tax_rate/2]).
:- use_module(helpers, [round_to_nearest_dollar/2]).
:- use_module(tests, [fact/2]).

% §3301 Rate of tax
futa_tax(Payer, Year, CaseID, Tax) :-
    is_employer(Payer, Year, CaseID),
    total_wages(Payer, Year, CaseID, TotalWages),
    futa_tax_rate(Year, Rate),
    RawTax is TotalWages * Rate,
    round_to_nearest_dollar(RawTax, Tax).
futa_tax(Payer, Year, CaseID, 0) :-
    \+ is_employer(Payer, Year, CaseID).
