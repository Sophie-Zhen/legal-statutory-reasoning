:- module(section3306,
          [ is_employer/3, % is_employer(Entity, Year, CaseID)
            total_wages/4, % total_wages(Employer, Year, CaseID, TotalWages)
            is_wages/4,    % is_wages(Payment, Employer, Employee, Year)
            is_employment/4, % is_employment(Service, Employer, Employee, Year)
            is_employment_exception_child_parent/3, % is_employment_exception_child_parent(Employer, Employee, Year)
            is_wage_exception_termination/4, % is_wage_exception_termination(Payer, Payee, Payment, Year)
            is_wage_exception_not_in_business_course/3, % is_wage_exception_not_in_business_course(Payer, Payee, Year)
            is_employer_general/3 % is_employer_general(Entity, Year, CaseID)
          ]).

:- use_module(tests, [fact/2]).
:- use_module(knowledge_base, [futa_wage_base/2, futa_employer_threshold/3]).
:- use_module(helpers, [sum_list/2, calculate_age_at_year_end/3]).


% §3306(a) Employer
is_employer(Entity, Year, CaseID) :-
    is_employer_general(Entity, Year, CaseID).
is_employer(Entity, Year, CaseID) :-
    is_employer_agricultural(Entity, Year, CaseID).
is_employer(Entity, Year, CaseID) :-
    is_employer_domestic(Entity, Year, CaseID).

is_employer_general(Entity, Year, CaseID) :-
    \+ fact(CaseID, payment_for_service(Entity, _, _, _, domestic)),
    (   paid_wages_threshold(Entity, Year, CaseID, general_wages)
    ;   employed_days_threshold(Entity, Year, CaseID, general_employees)
    ).

is_employer_agricultural(Entity, Year, CaseID) :-
    fact(CaseID, service_type(Entity, _, agricultural)),
    (   paid_wages_threshold(Entity, Year, CaseID, agricultural_wages)
    ;   employed_days_threshold(Entity, Year, CaseID, agricultural_employees)
    ).

is_employer_domestic(Entity, Year, CaseID) :-
    fact(CaseID, payment_for_service(Entity, _, _, _, domestic)),
    paid_wages_threshold(Entity, Year, CaseID, domestic_wages).

paid_wages_threshold(Entity, Year, CaseID, Type) :-
    futa_employer_threshold(Year, Type, Threshold),
    findall(Amount, (fact(CaseID, payment_for_service(Entity, _, Amount, Year, _))), AmountsCurrentYear),
    sum_list(AmountsCurrentYear, SumCurrent),
    (   SumCurrent >= Threshold -> true
    ;   PrevYear is Year - 1,
        findall(Amount, (fact(CaseID, payment_for_service(Entity, _, Amount, PrevYear, _))), AmountsPrevYear),
        sum_list(AmountsPrevYear, SumPrev),
        SumPrev >= Threshold
    ).

employed_days_threshold(Entity, Year, CaseID, Type) :-
    futa_employer_threshold(Year, Type, EmployeeCountThreshold),
    futa_employer_threshold(Year, weeks, WeekThreshold),
    (   meets_employee_day_count(Entity, Year, CaseID, EmployeeCountThreshold, WeekThreshold)
    ;   PrevYear is Year - 1,
        meets_employee_day_count(Entity, Year, CaseID, EmployeeCountThreshold, WeekThreshold)
    ).

meets_employee_day_count(Entity, Year, CaseID, EmployeeCountThreshold, WeekThreshold) :-
    findall(Week, (
        fact(CaseID, employed_on_date(Entity, _, date(Year, _, _))),
        fact(CaseID, week_of_year(_, Week)) % Needs a fact to map dates to calendar weeks
        ), Weeks),
    sort(Weeks, UniqueWeeks),
    length(UniqueWeeks, Count),
    Count >= WeekThreshold.

% §3306(b) Wages
total_wages(Employer, Year, CaseID, TotalWages) :-
    futa_wage_base(Year, Base),
    findall(Wage, (
        fact(CaseID, payment_for_service(Employer, Employee, Amount, Year, _)),
        is_wages(Amount, Employer, Employee, Year)
    ), AllWages),
    % Here we need to cap per employee, not just sum all payments
    findall(Employee, (fact(CaseID, payment_for_service(Employer, Employee, _, Year, _))), Employees),
    setof(E, E in Employees, UniqueEmployees), % get unique employees
    employee_capped_wages(UniqueEmployees, Employer, Year, CaseID, Base, CappedWagesList),
    sum_list(CappedWagesList, TotalWages).

employee_capped_wages([], _, _, _, _, []).
employee_capped_wages([E|Es], Employer, Year, CaseID, Base, [Capped|Rest]) :-
    findall(Amount, (fact(CaseID, payment_for_service(Employer, E, Amount, Year, _)), is_wages(Amount, Employer, E, Year)), Payments),
    sum_list(Payments, TotalForEmployee),
    Capped is min(TotalForEmployee, Base),
    employee_capped_wages(Es, Employer, Year, CaseID, Base, Rest).

is_wages(_Payment, Employer, Employee, Year) :-
    is_employment(_, Employer, Employee, Year),
    \+ is_wage_exception(_Payment, Employer, Employee, Year).

% §3306(b) Wage Exceptions
is_wage_exception(Payment, Payer, Payee, Year) :-
    is_wage_exception_termination(Payer, Payee, Payment, Year).
is_wage_exception(Payment, Payer, Payee, Year) :-
    is_wage_exception_not_in_business_course(Payer, Payee, Year).
% Other exceptions not fully modeled from given cases
% (b)(2) sickness/disability, (b)(11) non-cash ag labor etc.

% §3306(b)(10)(A)
is_wage_exception_termination(Payer, Payee, _Payment, Year) :-
    fact(CaseID, employment_termination_reason(Payer, Payee, Year, Reason)),
    member(Reason, [death, retirement_for_disability]),
    fact(CaseID, payment_under_plan(Payer, _)).

% §3306(b)(7)
is_wage_exception_not_in_business_course(Payer, Payee, Year) :-
    fact(CaseID, payment_for_service(Payer, Payee, _, Year, ServiceType)),
    \+ fact(CaseID, is_trade_or_business(Payer, ServiceType)).


% §3306(c) Employment
is_employment(_Service, Employer, Employee, Year) :-
    fact(CaseID, service_performed_in_us(Employer, Employee, Year)),
    \+ is_employment_exception(Employer, Employee, Year).
% Other cases like (B) not modeled from given cases.

% §3306(c) Employment Exceptions
is_employment_exception(Employer, Employee, Year) :-
    is_employment_exception_child_parent(Employer, Employee, Year).
% Other exceptions not fully modeled...
% (c)(2) domestic service under threshold, (c)(10) student, etc.

% §3306(c)(5)
is_employment_exception_child_parent(Employer, Employee, _Year) :-
    fact(CaseID, child_of(Employer, Employee)).
is_employment_exception_child_parent(Employer, Employee, _Year) :-
    fact(CaseID, daughter_of(Employer, Employee)).
is_employment_exception_child_parent(Employer, Employee, _Year) :-
    fact(CaseID, son_of(Employer, Employee)).
is_employment_exception_child_parent(Employer, Employee, _Year) :-
    fact(CaseID, spouse(Employer, Employee)).
is_employment_exception_child_parent(Employer, Employee, Year) :-
    fact(CaseID, child_of(Employee, Employer)),
    fact(CaseID, birth_year(Employee, BirthYear)),
    calculate_age_at_year_end(BirthYear, Year, Age),
    Age < 21.
