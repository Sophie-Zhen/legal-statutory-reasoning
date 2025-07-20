:- module(section1,
    [
        tax_imposed/5
    ]).

:- use_module(knowledge_base, [tax_brackets/3]).
:- use_module(helpers, [calculate_tax_from_brackets/3]).
:- use_module(section2, [is_surviving_spouse/3, is_head_of_household/3]).
:- use_module(section7703, [is_married/4]).
:- use_module(section63, [determine_filing_status_for_63/4]).

:- multifile fact/2.

tax_imposed(CaseID, Taxpayer, Year, TaxableIncome, Tax) :-
    determine_filing_status_for_63(CaseID, Taxpayer, Year, FilingStatus),
    tax_imposed(FilingStatus, Year, TaxableIncome, Tax).

tax_imposed(FilingStatus, Year, TaxableIncome, Tax) :-
    member(FilingStatus, [married_filing_jointly, surviving_spouse]), !,
    tax_brackets(Year, married_filing_jointly, Brackets),
    calculate_tax_from_brackets(TaxableIncome, Brackets, Tax).
tax_imposed(head_of_household, Year, TaxableIncome, Tax) :- !,
    tax_brackets(Year, head_of_household, Brackets),
    calculate_tax_from_brackets(TaxableIncome, Brackets, Tax).
tax_imposed(unmarried, Year, TaxableIncome, Tax) :- !,
    tax_brackets(Year, unmarried, Brackets),
    calculate_tax_from_brackets(TaxableIncome, Brackets, Tax).
tax_imposed(married_filing_separately, Year, TaxableIncome, Tax) :- !,
    tax_brackets(Year, married_filing_separately, Brackets),
    calculate_tax_from_brackets(TaxableIncome, Brackets, Tax).
