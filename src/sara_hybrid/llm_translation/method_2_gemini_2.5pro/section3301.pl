:- module(section3301,
          [
            s3301_excise_tax/4 % s3301_excise_tax(CaseID, EmployerID, CalendarYear, Tax)
          ]).

:- use_module(section3306, [s3306_a_is_employer/3, s3306_b_total_taxable_wages/4]).
:- use_module(helpers, [round_to_dollars/2]).

s3301_excise_tax(CaseID, EmployerID, CalendarYear, Tax) :-
    s3306_a_is_employer(CaseID, EmployerID, CalendarYear), % Confirms is employer
    s3306_b_total_taxable_wages(CaseID, EmployerID, CalendarYear, TotalTaxableWages), % Gets S3306(b) wages
    RawTax is 0.06 * TotalTaxableWages,
    round_to_dollars(RawTax, Tax).