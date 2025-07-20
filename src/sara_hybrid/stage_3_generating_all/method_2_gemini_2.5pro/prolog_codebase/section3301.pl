:- module(section3301,
    [
        futa_excise_tax/4
    ]).

:- use_module(knowledge_base, [futa_tax_rate/2, futa_wage_base/2]).
:- use_module(section3306, [is_employer/4, is_employment/5, is_wages/6]).
:- use_module(library(lists), [sum_list/2]).

:- multifile fact/2.

futa_excise_tax(CaseID, Employer, Year, Tax) :-
    is_employer(CaseID, Employer, Year, true),
    !,
    findall(
        TaxableWage,
        (   fact(CaseID, paid_wages(Employer, Employee, Year, _, _)),
            is_taxable_wage_for_employee(CaseID, Employer, Employee, Year, TaxableWage)
        ),
        TaxableWages
    ),
    sum_list(TaxableWages, TotalTaxableWages),
    futa_tax_rate(Year, Rate),
    Tax is TotalTaxableWages * Rate.
futa_excise_tax(_CaseID, _Employer, _Year, 0).

is_taxable_wage_for_employee(CaseID, Employer, Employee, Year, TaxableWage) :-
    findall(
        Amount,
        (   fact(CaseID, paid_wages(Employer, Employee, Year, Amount, _)),
            is_employment(CaseID, Employer, Employee, Year, true),
            is_wages(CaseID, Employer, Employee, Amount, Year, true)
        ),
        Wages
    ),
    sum_list(Wages, TotalWages),
    futa_wage_base(Year, WageBase),
    TaxableWage is min(TotalWages, WageBase).
