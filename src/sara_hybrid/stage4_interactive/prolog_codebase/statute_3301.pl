:- module(statute_3301,
          [ futa_tax/3
          ]).

/**
 * statute_3301.pl
 *
 * This module implements §3301, which imposes the FUTA (Federal Unemployment
 * Tax Act) excise tax on employers.
 *
 * The core logic calculates the total taxable wages paid by an employer during
 * a calendar year and applies the statutory tax rate. It relies on definitions
 * from §3306 to determine who is an employer, what constitutes employment,
 * and what payments are considered wages.
 */

:- use_module(knowledge_base).
:- use_module(statute_3306).

% The system will provide the 'fact' predicates at runtime.
:- discontiguous fact/1, fact/2, fact/3, fact/4.

% futa_tax(+Employer, +Year, -Tax)
%
% Calculates the FUTA tax for a given employer for a calendar year.
% The tax is 6% of the total wages paid with respect to employment.
futa_tax(Employer, Year, Tax) :-
    % First, confirm the person is an employer under §3306(a).
    statute_3306:is_employer(Employer, Year, _),
    !, % If not an employer, this predicate fails.
    calculate_total_taxable_wages(Employer, Year, TotalWages),
    Tax is 0.06 * TotalWages.

% calculate_total_taxable_wages(+Employer, +Year, -TotalWages)
%
% Sums the taxable wages for all employees of the employer for the year.
calculate_total_taxable_wages(Employer, Year, TotalWages) :-
    % Find all unique individuals who performed 'employment' services.
    findall(Employee, statute_3306:is_employment(Employer, Employee, Year), Employees),
    list_to_set(Employees, UniqueEmployees),
    % Calculate and sum the taxable wages for each employee.
    calculate_wages_for_employee_list(Employer, Year, UniqueEmployees, TotalWages).

calculate_wages_for_employee_list(_, _, [], 0).
calculate_wages_for_employee_list(Employer, Year, [Employee | Rest], TotalWages) :-
    calculate_employee_taxable_wages(Employer, Employee, Year, EmployeeWages),
    calculate_wages_for_employee_list(Employer, Year, Rest, RestWages),
    TotalWages is EmployeeWages + RestWages.

% calculate_employee_taxable_wages(+Employer, +Employee, +Year, -TaxableWages)
%
% Calculates the taxable wages for a single employee. This involves summing
% all remuneration that is not otherwise excluded, and then applying the
% §3306(b)(1) wage base cap ($7,000).
calculate_employee_taxable_wages(Employer, Employee, Year, TaxableWages) :-
    % Find all payments that qualify as wages, ignoring the wage base cap for now.
    findall(Amount,
            is_uncapped_wage(Employer, Employee, Amount, Year),
            Payments),
    sum_list(Payments, TotalRemuneration),
    % Apply the FUTA wage base limit.
    knowledge_base:futa_wage_base(default, Cap),
    TaxableWages is min(TotalRemuneration, Cap).

% is_uncapped_wage(+Employer, +Employee, +Amount, +Year)
%
% Determines if a payment is a wage, checking all exceptions from §3306(b)
% *except* for the main wage base cap itself (§3306(b)(1)), as the cap is
% applied after summing all other valid remuneration.
is_uncapped_wage(Employer, Employee, Amount, Year) :-
    fact(remuneration_for_employment(Employer, Employee, Amount, Year)),
    \+ is_non_cap_wage_exception(Employer, Employee, Amount, Year).

% is_non_cap_wage_exception(+Employer, +Employee, +Amount, +Year)
%
% Groups the specific wage exception checks from §3306.
% This deliberately omits §3306(b)(1).
is_non_cap_wage_exception(Employer, Employee, Amount, Year) :-
    % A payment is identified by its amount and year for the purpose of the fact lookup.
    fact(payment_year(Amount, Year)),
    statute_3306:is_wage_exception_b7(Employer, Employee, Amount).
is_non_cap_wage_exception(Employer, Employee, Amount, _Year) :-
    statute_3306:is_wage_exception_b10(Amount, Employer, Employee).
% Other exceptions from §3306(b), like (b)(2), (b)(11), etc., would be added here.