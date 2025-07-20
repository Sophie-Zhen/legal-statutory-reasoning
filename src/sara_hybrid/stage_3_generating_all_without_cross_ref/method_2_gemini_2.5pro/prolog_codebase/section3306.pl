:- module(section3306,
          [ is_employer/3,
            is_employer_a1/3,
            is_wages/4,
            is_employment/4,
            is_wage_exception_b7/2,
            is_wage_exception_b10/2,
            is_employment_exception_c5/4
          ]).

:- use_module(knowledge_base).
:- use_module(helpers, [get_age_at_year_end/3]).

:- multifile fact/2.
/*
    §3306. Definitions (for FUTA tax)
*/

% is_employer(CaseID, Person, Year)
is_employer(CaseID, Person, Year) :-
    is_employer_a1(CaseID, Person, Year);
    is_employer_a2(CaseID, Person, Year);
    is_employer_a3(CaseID, Person, Year).

% is_employer_a1(CaseID, Person, Year) - General Rule
is_employer_a1(CaseID, Person, Year) :-
    futa_employer_wage_threshold_general(Year, Threshold),
    (   total_wages_paid_in_year(CaseID, Person, Year, TotalWages), TotalWages >= Threshold
    ;   total_wages_paid_in_year(CaseID, Person, Year - 1, TotalWages), TotalWages >= Threshold
    ),
    \+ wages_paid_for_domestic_service_only(CaseID, Person, Year).
is_employer_a1(CaseID, Person, Year) :-
    futa_employer_days_test_general(DayThreshold),
    (   employed_on_n_days(CaseID, Person, Year, Days), Days >= DayThreshold
    ;   employed_on_n_days(CaseID, Person, Year - 1, Days), Days >= DayThreshold
    ),
    \+ employment_is_domestic_service_only(CaseID, Person, Year).


% is_employer_a2(CaseID, Person, Year) - Agricultural Labor
is_employer_a2(CaseID, Person, Year) :-
    futa_employer_wage_threshold_ag(Year, Threshold),
    (   total_wages_paid_for_ag_labor(CaseID, Person, Year, Wages), Wages >= Threshold
    ;   total_wages_paid_for_ag_labor(CaseID, Person, Year-1, Wages), Wages >= Threshold
    ).
is_employer_a2(CaseID, Person, Year) :-
    futa_employer_days_test_ag(DayThreshold),
    futa_ag_labor_employee_threshold(EmployeeThreshold),
    (   employed_ag_labor_on_n_days(CaseID, Person, Year, EmployeeThreshold, Days), Days >= DayThreshold
    ;   employed_ag_labor_on_n_days(CaseID, Person, Year-1, EmployeeThreshold, Days), Days >= DayThreshold
    ).

% is_employer_a3(CaseID, Person, Year) - Domestic Service
is_employer_a3(CaseID, Person, Year) :-
    futa_employer_wage_threshold_domestic(Year, Threshold),
    (   total_wages_paid_for_domestic_service(CaseID, Person, Year, Wages), Wages >= Threshold
    ;   total_wages_paid_for_domestic_service(CaseID, Person, Year-1, Wages), Wages >= Threshold
    ).

% is_wages(CaseID, Payer, Payee, Year)
% §3306(b) - Very broad, assuming most remuneration is wages unless an exception applies.
is_wages(CaseID, Payer, Payee, Year) :-
    fact(CaseID, paid(Payer, Payee, Year, _, _)),
    \+ is_wage_exception(CaseID, Payer, Payee, Year).

% is_wage_exception(CaseID, Payer, Payee, Year)
is_wage_exception(CaseID, Payer, Payee, Year) :-
    % §3306(b)(1) Remuneration over $7,000
    futa_wage_base_limit(Year, Limit),
    fact(CaseID, paid(Payer, Payee, Year, Amount, _)),
    findall(P, (fact(CaseID, paid(Payer, Payee, Year, P, _)), P < Amount), PriorPayments),
    sum_list(PriorPayments, TotalPrior),
    TotalPrior < Limit,
    TotalPrior + Amount > Limit.
is_wage_exception(CaseID, _Payer, _Payee, _Year) :-
    % Simplified logic for other exceptions, e.g. from a plan
    fact(CaseID, payment_from_sickness_plan(_)).
is_wage_exception(CaseID, Payer, Payee, Year) :-
    fact(CaseID, paid(Payer, Payee, Year, _, PaymentID)),
    is_wage_exception_b7(CaseID, PaymentID).
is_wage_exception(CaseID, Payer, Payee, Year) :-
    fact(CaseID, paid(Payer, Payee, Year, _, PaymentID)),
    is_wage_exception_b10(CaseID, PaymentID).

% is_wage_exception_b7(CaseID, PaymentID)
% §3306(b)(7) non-cash for service not in employer's trade or business
is_wage_exception_b7(CaseID, PaymentID) :-
    fact(CaseID, payment_details(PaymentID, Medium, Service)),
    Medium \== cash,
    fact(CaseID, employer_trade_or_business(Employer, Business)),
    fact(CaseID, service_details(Service, _, Employer, _)),
    Service \== Business.

% is_wage_exception_b10(CaseID, PaymentID)
% §3306(b)(10) Termination payments (death, disability)
is_wage_exception_b10(CaseID, PaymentID) :-
    fact(CaseID, payment_details(PaymentID, _, Service)),
    fact(CaseID, service_details(Service, Employee, Employer, _)),
    fact(CaseID, paid_under_plan(Employer, _)),
    (   fact(CaseID, employment_terminated_due_to(Employee, Employer, death))
    ;   fact(CaseID, employment_terminated_due_to(Employee, Employer, disability))
    ),
    \+ fact(CaseID, payment_would_have_been_made_anyway(PaymentID)).

% is_employment(CaseID, Employer, Employee, Year)
% §3306(c) - Broad definition, check for exceptions.
is_employment(CaseID, Employer, Employee, Year) :-
    fact(CaseID, service_performed_in_us(Employee, Employer, Year)),
    \+ is_employment_exception(CaseID, Employer, Employee, Year).

% is_employment_exception(CaseID, Employer, Employee, Year)
is_employment_exception(CaseID, Employer, Employee, Year) :-
    is_employment_exception_c5(CaseID, Employee, Employer, Year).
is_employment_exception(CaseID, Employer, Employee, _Year) :-
    % Other exceptions are identified by facts
    (   fact(CaseID, employed_by_us_government(Employee, Employer))
    ;   fact(CaseID, employed_by_state_government(Employee, Employer))
    ;   fact(CaseID, student_employee_at_school(Employee, Employer))
    ;   fact(CaseID, patient_employee_at_hospital(Employee, Employer))
    ;   fact(CaseID, child_employee_under_21(Employee, Employer))
    ).

% is_employment_exception_c5(CaseID, Employee, Employer, Year)
% §3306(c)(5) Service in employ of family
is_employment_exception_c5(CaseID, Employee, Employer, _Year) :-
    (   fact(CaseID, child_of(Employer, Employee)) % son, daughter
    ;   fact(CaseID, spouse_of(Employee, Employer))
    ).
is_employment_exception_c5(CaseID, Employee, Employer, Year) :-
    fact(CaseID, parent_of(Employer, Employee)), % father or mother
    fact(CaseID, date_of_birth(Employee, DOB)),
    get_age_at_year_end(DOB, Year, Age),
    child_age_under_employment_exception(AgeLimit),
    Age < AgeLimit.

% --- Helper predicates for internal logic ---
total_wages_paid_in_year(CaseID, Person, Year, TotalWages) :-
    findall(Amount, (
        is_wages(CaseID, Person, Payee, Year),
        fact(CaseID, paid(Person, Payee, Year, Amount, _))
    ), Wages),
    sum_list(Wages, TotalWages).

wages_paid_for_domestic_service_only(CaseID, Person, Year) :-
    forall(fact(CaseID, paid(Person, _, Year, _, _)),
           fact(CaseID, service_is_domestic(Person, _))).

employment_is_domestic_service_only(CaseID, Person, Year) :-
    forall(fact(CaseID, employed(Person, _, Year)),
           fact(CaseID, service_is_domestic(Person, _))).

total_wages_paid_for_ag_labor(CaseID, Person, Year, TotalWages) :-
    findall(Amount, (
        fact(CaseID, paid(Person, Payee, Year, Amount, _)),
        fact(CaseID, service_is_ag_labor(Payee, Person))
        ), Wages),
    sum_list(Wages, TotalWages).

total_wages_paid_for_domestic_service(CaseID, Person, Year, TotalWages) :-
    findall(Amount, (
        fact(CaseID, paid(Person, Payee, Year, Amount, _)),
        fact(CaseID, service_is_domestic(Payee, Person))
        ), Wages),
    sum_list(Wages, TotalWages).

employed_on_n_days(CaseID, Person, Year, Days) :-
    findall(date(Year,M,D), fact(CaseID, employed_on_date(Person, _, date(Year,M,D))), Dates),
    length(Dates, Days).

employed_ag_labor_on_n_days(CaseID, Person, Year, EmployeeThreshold, NumWeeks) :-
    findall(Week, (
        fact(CaseID, employed_ag_labor_on_date(Person, _, date(Year,_,_), Week)),
        findall(E, distinct(E, fact(CaseID, employed_ag_labor_on_date(Person, E, date(Year,_,_), Week))), Employees),
        length(Employees, NumEmployees),
        NumEmployees >= EmployeeThreshold
    ), Weeks),
    list_to_set(Weeks, UniqueWeeks),
    length(UniqueWeeks, NumWeeks).
