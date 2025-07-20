:- module(section3301,
          [ futa_tax/4
          ]).

:- use_module(section3306, [is_employer/3, is_wages/4, is_employment/4]).
:- use_module(knowledge_base, [futa_tax_rate/2, futa_wage_base_limit/2]).

:- multifile fact/2.

/*
    §3301. Rate of tax
    Calculates the Federal Unemployment Tax Act (FUTA) excise tax.
*/

% futa_tax(CaseID, Employer, Year, Tax)
futa_tax(CaseID, Employer, Year, Tax) :-
    is_employer(CaseID, Employer, Year), !,
    futa_tax_rate(Year, Rate),
    total_taxable_wages(CaseID, Employer, Year, TaxableWages),
    Tax is TaxableWages * Rate.
futa_tax(CaseID, Employer, Year, 0) :-
    \+ is_employer(CaseID, Employer, Year).

% total_taxable_wages(CaseID, Employer, Year, TotalTaxableWages)
% Sums the taxable wages for all employees, capped at the wage base limit per employee.
total_taxable_wages(CaseID, Employer, Year, TotalTaxableWages) :-
    findall(Employee, fact(CaseID, employed(Employer, Employee, Year)), Employees),
    list_to_set(Employees, UniqueEmployees),
    futa_wage_base_limit(Year, Limit),
    sum_employee_wages(CaseID, Employer, Year, UniqueEmployees, Limit, 0, TotalTaxableWages).

sum_employee_wages(_CaseID, _Employer, _Year, [], _Limit, Acc, Acc).
sum_employee_wages(CaseID, Employer, Year, [Employee|Rest], Limit, Acc, Total) :-
    is_employment(CaseID, Employer, Employee, Year),
    findall(Amount, (
        is_wages(CaseID, Employer, Employee, Year),
        fact(CaseID, paid(Employer, Employee, Year, Amount, _))
    ), Payments),
    sum_list(Payments, TotalPaid),
    TaxableForEmployee is min(TotalPaid, Limit),
    NewAcc is Acc + TaxableForEmployee,
    sum_employee_wages(CaseID, Employer, Year, Rest, Limit, NewAcc, Total).
sum_employee_wages(CaseID, Employer, Year, [Employee|Rest], Limit, Acc, Total) :-
    \+ is_employment(CaseID, Employer, Employee, Year),
    sum_employee_wages(CaseID, Employer, Year, Rest, Limit, Acc, Total).
