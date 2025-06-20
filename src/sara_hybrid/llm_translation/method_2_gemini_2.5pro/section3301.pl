:- module(section3301,
          [ s3301_excise_tax_due/4 % s3301_excise_tax_due(CaseID, EmployerID, CalendarYear, TaxAmount)
          ]).

:- use_module(helpers, [round_to_dollars/2]).
:- use_module(section3306, [s3306_a_is_employer/4, s3306_b_total_taxable_wages/4]).

:- dynamic fact/2.

s3301_excise_tax_due(CaseID, EmployerID, CalendarYear, TaxAmount) :-
    s3306_a_is_employer(CaseID, EmployerID, CalendarYear, true),
    s3306_b_total_taxable_wages(CaseID, EmployerID, CalendarYear, TotalWages),
    RawTax is 0.06 * TotalWages,
    round_to_dollars(RawTax, TaxAmount).