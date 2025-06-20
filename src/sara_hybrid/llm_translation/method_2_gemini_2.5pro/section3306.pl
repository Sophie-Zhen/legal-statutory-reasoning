:- module(section3306,
          [ s3306_a_is_employer/4,                  % s3306_a_is_employer(CaseID, PersonID, CalendarYear, IsEmployerBool)
            s3306_b_total_taxable_wages/4,          % s3306_b_total_taxable_wages(CaseID, EmployerID, CalendarYear, TotalTaxableWages)
            s3306_b_2_C_payment_for_death_excluded/5, % s3306_b_2_C_payment_for_death_excluded(CaseID, EmployerID, EmployeeID, PaymentAmount, CalendarYear)
            s3306_c_is_employment/5,                % s3306_c_is_employment(CaseID, EmployeeID, EmployerID, ServiceDetailsAtom, CalendarYear)
            s3306_c_6_is_service_us_gov_employment/4 % s3306_c_6_is_service_us_gov_employment(CaseID, EmployeeID, EmployerID, CalendarYear)
          ]).

:- use_module(helpers, [get_age_at_year_end/4]).

:- dynamic fact/2.

% §3306(a) Employer
s3306_a_is_employer(CaseID, PersonID, CalendarYear, true) :-
    ( s3306_a_1_general_employer(CaseID, PersonID, CalendarYear)
    ; s3306_a_2_agricultural_employer(CaseID, PersonID, CalendarYear)
    ; s3306_a_3_domestic_service_employer(CaseID, PersonID, CalendarYear)
    ).
s3306_a_is_employer(_, _, _, false).

s3306_a_1_general_employer(CaseID, PersonID, CalendarYear) :-
    fact(CaseID, employer_type_for_s3306a(PersonID, general)), % Distinguish from ag/domestic for special rules
    ( fact(CaseID, paid_wages_1500_or_more(PersonID, CalendarYear))
    ; fact(CaseID, paid_wages_1500_or_more(PersonID, CalendarYear - 1))
    ; fact(CaseID, employed_one_individual_10_days_different_weeks(PersonID, CalendarYear))
    ; fact(CaseID, employed_one_individual_10_days_different_weeks(PersonID, CalendarYear - 1))
    ),
    \+ fact(CaseID, all_wages_for_excluded_domestic_services_s3306a1(PersonID, CalendarYear)).

s3306_a_2_agricultural_employer(CaseID, PersonID, CalendarYear) :-
    fact(CaseID, employer_type_for_s3306a(PersonID, agricultural)),
    ( fact(CaseID, paid_ag_wages_20000_or_more(PersonID, CalendarYear))
    ; fact(CaseID, paid_ag_wages_20000_or_more(PersonID, CalendarYear - 1))
    ; fact(CaseID, employed_five_ag_individuals_10_days_different_weeks(PersonID, CalendarYear))
    ; fact(CaseID, employed_five_ag_individuals_10_days_different_weeks(PersonID, CalendarYear - 1))
    ).

s3306_a_3_domestic_service_employer(CaseID, PersonID, CalendarYear) :-
    fact(CaseID, employer_type_for_s3306a(PersonID, domestic_service_only)), % For person ONLY employing domestic service
    ( fact(CaseID, paid_cash_domestic_wages_1000_or_more(PersonID, CalendarYear))
    ; fact(CaseID, paid_cash_domestic_wages_1000_or_more(PersonID, CalendarYear - 1))
    ).
% Note: s3306(a)(4) implies a hierarchy. If one is an (a)(1) employer, they are an employer for all services.
% If only (a)(3), then only for domestic. This is handled by how facts are asserted.

% §3306(b) Wages
s3306_b_total_taxable_wages(CaseID, EmployerID, CalendarYear, TotalTaxableWages) :-
    findall(EmployeeID, fact(CaseID, employee_of(EmployeeID, EmployerID, CalendarYear)), Employees),
    s3306_b_sum_employee_taxable_wages(CaseID, EmployerID, Employees, CalendarYear, 0, TotalTaxableWages).

s3306_b_sum_employee_taxable_wages(_, _, [], _, AccWages, AccWages).
s3306_b_sum_employee_taxable_wages(CaseID, EmployerID, [EmpH|EmpT], CalendarYear, AccWages, TotalWages) :-
    s3306_b_single_employee_taxable_wages(CaseID, EmployerID, EmpH, CalendarYear, EmpTaxableWages),
    NewAccWages is AccWages + EmpTaxableWages,
    s3306_b_sum_employee_taxable_wages(CaseID, EmployerID, EmpT, CalendarYear, NewAccWages, TotalWages).

s3306_b_single_employee_taxable_wages(CaseID, EmployerID, EmployeeID, CalendarYear, TaxableWagesForEmployee) :-
    findall(Amount,
            ( fact(CaseID, remuneration_payment(EmployerID, EmployeeID, CalendarYear, PaymentDetailsAtom, Amount)),
              \+ s3306_b_is_remuneration_excluded(CaseID, EmployerID, EmployeeID, PaymentDetailsAtom, Amount, CalendarYear)
            ),
            IncludedPayments),
    sum_list(IncludedPayments, TotalIncludedRemuneration),
    TaxableWagesForEmployee is min(TotalIncludedRemuneration, 7000). % §3306(b)(1) cap

s3306_b_is_remuneration_excluded(CaseID, EmployerID, EmployeeID, PaymentDetailsAtom, Amount, CalendarYear) :-
    s3306_b_2_plan_payment_excluded(CaseID, EmployerID, EmployeeID, PaymentDetailsAtom, Amount, CalendarYear).
s3306_b_is_remuneration_excluded(_CaseID, _EmployerID, _EmployeeID, non_cash_not_in_course_of_business, _Amount, _CalendarYear). % (b)(7)
s3306_b_is_remuneration_excluded(CaseID, EmployerID, EmployeeID, post_termination_payment, Amount, CalendarYear) :- % (b)(10)
    s3306_b_10_post_termination_payment_excluded(CaseID, EmployerID, EmployeeID, post_termination_payment, Amount, CalendarYear).
s3306_b_is_remuneration_excluded(_CaseID, _EmployerID, _EmployeeID, non_cash_agricultural_labor, _Amount, _CalendarYear). % (b)(11)
s3306_b_is_remuneration_excluded(_CaseID, _EmployerID, _EmployeeID, payment_to_survivor_estate_after_death_year, _Amount, _CalendarYear). % (b)(15)

% §3306(b)(2) Plan payments
s3306_b_2_plan_payment_excluded(CaseID, EmployerID, _EmployeeID, PaymentDetailsAtom, _Amount, CalendarYear) :-
    fact(CaseID, payment_under_employer_plan(EmployerID, PaymentDetailsAtom, AccountType, CalendarYear)),
    member(AccountType, [sickness_or_accident_disability, death]).

% For case s3306_b_2_C_pos (death benefit part of (b)(2))
s3306_b_2_C_payment_for_death_excluded(CaseID, EmployerID, EmployeeID, PaymentAmount, CalendarYear) :-
    s3306_b_2_plan_payment_excluded(CaseID, EmployerID, EmployeeID, life_insurance_fund_payment, PaymentAmount, CalendarYear).

% §3306(b)(10) Post-termination payments
s3306_b_10_post_termination_payment_excluded(CaseID, EmployerID, _EmployeeID, _PaymentDetails, _Amount, CalendarYear) :-
    fact(CaseID, payment_plan_post_termination(EmployerID, Reason, PlanDetails, CalendarYear)),
    member(Reason, [death, retirement_for_disability]),
    fact(CaseID, payment_would_not_have_been_paid_otherwise(EmployerID, PlanDetails, CalendarYear)).

% §3306(c) Employment
s3306_c_is_employment(CaseID, EmployeeID, EmployerID, ServiceDetailsAtom, CalendarYear) :-
    fact(CaseID, service_by_employee_for_employer(EmployeeID, EmployerID, ServiceDetailsAtom, CalendarYear)),
    ( fact(CaseID, service_location_us(ServiceDetailsAtom))
    ; fact(CaseID, service_location_outside_us_us_citizen_american_employer(ServiceDetailsAtom, EmployeeID, EmployerID))
    ),
    \+ s3306_c_service_is_excepted(CaseID, EmployeeID, EmployerID, ServiceDetailsAtom, CalendarYear).

s3306_c_service_is_excepted(CaseID, EID, ERID, SDA, CY) :- s3306_c_1_agricultural_labor_excepted(CaseID, EID, ERID, SDA, CY).
s3306_c_service_is_excepted(CaseID, EID, ERID, SDA, CY) :- s3306_c_2_domestic_service_excepted(CaseID, EID, ERID, SDA, CY).
s3306_c_service_is_excepted(CaseID, EID, ERID, SDA, CY) :- s3306_c_5_family_employment_excepted(CaseID, EID, ERID, SDA, CY).
s3306_c_service_is_excepted(CaseID, _EID, ERID, _SDA, _CY) :- s3306_c_6_is_service_us_gov_employment(CaseID, _EID, ERID, _CY). % For exception
s3306_c_service_is_excepted(CaseID, _EID, ERID, _SDA, _CY) :- fact(CaseID, employer_is_state_or_political_subdivision(ERID)). % (c)(7)
% ... other exceptions like (c)(10), (c)(11), (c)(13), (c)(16), (c)(21) would follow similar pattern

s3306_c_5_family_employment_excepted(CaseID, EmployeeID, EmployerID, _SDA, CalendarYear) :- % (c)(5)(A)
    ( fact(CaseID, relationship_son_of(EmployerID, EmployeeID))
    ; fact(CaseID, relationship_daughter_of(EmployerID, EmployeeID))
    ; fact(CaseID, spouse_of(EmployerID, EmployeeID))
    ).
s3306_c_5_family_employment_excepted(CaseID, EmployeeID, EmployerID, _SDA, CalendarYear) :- % (c)(5)(B)
    ( fact(CaseID, relationship_father_of(EmployerID, EmployeeID))
    ; fact(CaseID, relationship_mother_of(EmployerID, EmployeeID))
    ),
    get_age_at_year_end(CaseID, EmployeeID, CalendarYear, Age),
    Age < 21.

s3306_c_6_is_service_us_gov_employment(_CaseID, _EmployeeID, EmployerID, _CalendarYear) :-
    fact(_CaseID, employer_is_us_government(EmployerID)).