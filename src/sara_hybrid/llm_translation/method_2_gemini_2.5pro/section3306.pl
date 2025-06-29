:- module(section3306,
          [
            s3306_a_is_employer/4, % s3306_a_is_employer(CaseID, PersonID, CalendarYear, IsEmployerBool)
            s3306_b_is_futa_wage/6, % s3306_b_is_futa_wage(CaseID, EmployerID, EmployeeID, CalendarYear, PaymentAmount, IsWageBool)
            s3306_b_total_futa_wages_for_employer/4, % s3306_b_total_futa_wages_for_employer(CaseID, EmployerID, CalendarYear, TotalFUTAWages)
            s3306_c_is_employment/5, % s3306_c_is_employment(CaseID, EmployerID, EmployeeID, ServiceDetails, IsEmploymentBool)
            s3306_c_5_family_employment_exception_applies/5, % s3306_c_5_family_employment_exception_applies(CaseID, EmployerID, EmployeeID, CalendarYear, AppliesBool)
            s3306_b_10_A_termination_payment_exception_applies/5, % s3306_b_10_A_termination_payment_exception_applies(CaseID, EmployerID, EmployeeID, PaymentDetails, AppliesBool)
            s3306_b_7_non_business_cash_remuneration_exception_applies/5 % s3306_b_7_non_business_cash_remuneration_exception_applies(CaseID, EmployerID, EmployeeID, PaymentDetails, AppliesBool)
          ]).
:- use_module(helpers, [get_age_at_year_end/4]).
:- use_module(tests, [fact/2]).
% s3306_a_is_employer(CaseID, PersonID, CalendarYear, IsEmployerBool)
% Determines if PersonID is an employer for CalendarYear.
s3306_a_is_employer(CaseID, PersonID, CalendarYear, true) :-
    s3306_a_1_general_employer(CaseID, PersonID, CalendarYear, true),
    \+ s3306_a_4_special_rule_domestic_only_check(CaseID, PersonID, CalendarYear, general_employer_false),
    !.
s3306_a_is_employer(CaseID, PersonID, CalendarYear, true) :-
    s3306_a_2_agricultural_employer(CaseID, PersonID, CalendarYear, true),
     \+ s3306_a_4_special_rule_domestic_only_check(CaseID, PersonID, CalendarYear, agricultural_employer_false),
    !.
s3306_a_is_employer(CaseID, PersonID, CalendarYear, true) :-
    s3306_a_3_domestic_service_employer(CaseID, PersonID, CalendarYear, true),
    !.
s3306_a_is_employer(_, _, _, false).
% s3306_a_1_general_employer(CaseID, PersonID, CalendarYear, IsGeneralEmployerBool)
s3306_a_1_general_employer(CaseID, PersonID, CalendarYear, true) :-
    ( s3306_a_1_A_wage_test_general(CaseID, PersonID, CalendarYear, true)
    ; s3306_a_1_B_employee_test_general(CaseID, PersonID, CalendarYear, true)
    ), !.
s3306_a_1_general_employer(_, _, _, false).
s3306_a_1_A_wage_test_general(CaseID, PersonID, CalendarYear, true) :-
    YearToCheck = CalendarYear ; YearToCheck is CalendarYear - 1,
    fact(CaseID, total_wages_paid_for_general_employment(PersonID, YearToCheck, Amount)),
    Amount >= 1500,
    !.
s3306_a_1_A_wage_test_general(CaseID, PersonID, CalendarYear, true) :- % Sum individual wages if total not available
    YearToCheck = CalendarYear ; YearToCheck is CalendarYear - 1,
    findall(WageAmount,
            ( fact(CaseID, paid_wage_to_employee_for_service(PersonID, EmployeeID, YearToCheck, WageAmount, ServiceType)),
              \+ ServiceType == domestic_service % Exclude domestic service wages for this test
            ),
            Wages),
    sum_list(Wages, TotalWages),
    TotalWages >= 1500,
    !.
s3306_a_1_A_wage_test_general(_, _, _, false).
s3306_a_1_B_employee_test_general(CaseID, PersonID, CalendarYear, true) :-
    YearToCheck = CalendarYear ; YearToCheck is CalendarYear - 1,
    fact(CaseID, employed_one_individual_on_x_days_general(PersonID, YearToCheck, NumDays)),
    NumDays >= 10, % "on each of some 10 days ... each day being in a different calendar week"
                  % Assuming fact 'employed_one_individual_on_x_days_general' respects "different calendar week"
    !.
s3306_a_1_B_employee_test_general(_, _, _, false).
% s3306_a_2_agricultural_employer(CaseID, PersonID, CalendarYear, IsAgriEmployerBool)
s3306_a_2_agricultural_employer(CaseID, PersonID, CalendarYear, true) :-
    ( s3306_a_2_A_wage_test_agricultural(CaseID, PersonID, CalendarYear, true)
    ; s3306_a_2_B_employee_test_agricultural(CaseID, PersonID, CalendarYear, true)
    ), !.
s3306_a_2_agricultural_employer(_, _, _, false).
s3306_a_2_A_wage_test_agricultural(CaseID, PersonID, CalendarYear, true) :-
    YearToCheck = CalendarYear ; YearToCheck is CalendarYear - 1,
    fact(CaseID, total_wages_paid_for_agricultural_labor(PersonID, YearToCheck, Amount)),
    Amount >= 20000,
    !.
s3306_a_2_A_wage_test_agricultural(_, _, _, false).
s3306_a_2_B_employee_test_agricultural(CaseID, PersonID, CalendarYear, true) :-
    YearToCheck = CalendarYear ; YearToCheck is CalendarYear - 1,
    fact(CaseID, employed_five_individuals_on_x_days_agricultural(PersonID, YearToCheck, NumDays)),
    NumDays >= 10, % "employed at least 5 individuals ... on each of some 10 days"
    !.
s3306_a_2_B_employee_test_agricultural(_, _, _, false).
% s3306_a_3_domestic_service_employer(CaseID, PersonID, CalendarYear, IsDomEmployerBool)
s3306_a_3_domestic_service_employer(CaseID, PersonID, CalendarYear, true) :-
    YearToCheck = CalendarYear ; YearToCheck is CalendarYear - 1,
    fact(CaseID, total_cash_wages_paid_for_domestic_service(PersonID, YearToCheck, Amount)),
    Amount >= 1000,
    !.
s3306_a_3_domestic_service_employer(_, _, _, false).
% s3306_a_4_special_rule_domestic_only_check(CaseID, PersonID, CalendarYear, CheckTypeAtom, IsFalseBool)
% If person is employer under (a)(3) [domestic], they are NOT employer for OTHER services
% UNLESS they also qualify under (a)(1) or (a)(2) for those other services.
% CheckTypeAtom: general_employer_false, agricultural_employer_false
% IsFalseBool: true if the general/agri employer status is voided by this rule.
s3306_a_4_special_rule_domestic_only_check(CaseID, PersonID, CalendarYear, general_employer_false) :-
    s3306_a_3_domestic_service_employer(CaseID, PersonID, CalendarYear, true), % Is a domestic employer
    \+ s3306_a_1_general_employer_for_other_services(CaseID, PersonID, CalendarYear, true), % But NOT general employer for non-domestic
    !.
s3306_a_4_special_rule_domestic_only_check(CaseID, PersonID, CalendarYear, agricultural_employer_false) :-
    s3306_a_3_domestic_service_employer(CaseID, PersonID, CalendarYear, true), % Is a domestic employer
    \+ s3306_a_2_agricultural_employer_for_other_services(CaseID, PersonID, CalendarYear, true), % But NOT agri employer for non-domestic
    !.
% Helper: s3306_a_1_general_employer_for_other_services (like a_1, but ensures wages/employment are non-domestic)
s3306_a_1_general_employer_for_other_services(CaseID, PersonID, CalendarYear, true) :-
    YearToCheck = CalendarYear ; YearToCheck is CalendarYear - 1,
    (   ( findall(WageAmount,
                ( fact(CaseID, paid_wage_to_employee_for_service(PersonID, _EmpID, YearToCheck, WageAmount, ServiceType)),
                  ServiceType \== domestic_service % Only non-domestic wages
                ), Wages),
          sum_list(Wages, TotalNonDomesticWages),
          TotalNonDomesticWages >= 1500
        )
    ;   ( fact(CaseID, employed_one_individual_on_x_days_non_domestic(PersonID, YearToCheck, NumDays)),
          NumDays >= 10
        )
    ), !.
s3306_a_1_general_employer_for_other_services(_, _, _, false).
% Similar helper for agricultural would be needed if there's a distinction.
% s3306_b_is_futa_wage(CaseID, EmployerID, EmployeeID, CalendarYear, PaymentAmount, PaymentDetails, IsWageBool)
% Determines if a specific payment is a FUTA wage.
% PaymentDetails might be a term like cash_remuneration, non_cash_benefit(Value), sickness_plan_payment etc.
s3306_b_is_futa_wage(CaseID, EmployerID, EmployeeID, CalendarYear, PaymentAmount, PaymentDetails, true) :-
    % General definition: "all remuneration for employment"
    s3306_c_is_employment(CaseID, EmployerID, EmployeeID, PaymentDetails, true), % Assuming PaymentDetails contains service info for employment check
    \+ s3306_b_exception_applies(CaseID, EmployerID, EmployeeID, CalendarYear, PaymentAmount, PaymentDetails, true),
    !.
s3306_b_is_futa_wage(_, _, _, _, _, _, false).
% s3306_b_exception_applies(CaseID, EmployerID, EmployeeID, CalendarYear, PaymentAmount, PaymentDetails, ExceptionAppliesBool)
s3306_b_exception_applies(CaseID, EmployerID, EmployeeID, CalendarYear, PaymentAmount, _PaymentDetails, true) :- % (1) $7000 wage cap
    s3306_b_1_wage_cap_exceeded(CaseID, EmployerID, EmployeeID, CalendarYear, PaymentAmount, true),
    !.
s3306_b_exception_applies(CaseID, _EmployerID, _EmployeeID, _CalendarYear, _PaymentAmount, PaymentDetails, true) :- % (2) Sickness, accident, death plan
    s3306_b_2_plan_payment_exception(CaseID, PaymentDetails, true), % PaymentDetails needs to identify type of payment
    !.
s3306_b_exception_applies(CaseID, EmployerID, EmployeeID, _CalendarYear, _PaymentAmount, PaymentDetails, true) :- % (7) Non-cash for non-business service
    s3306_b_7_non_business_cash_remuneration_exception_applies(CaseID, EmployerID, EmployeeID, PaymentDetails, true),
    !.
s3306_b_exception_applies(CaseID, EmployerID, EmployeeID, _CalendarYear, _PaymentAmount, PaymentDetails, true) :- % (10) Certain termination payments
    s3306_b_10_termination_payment_exception(CaseID, EmployerID, EmployeeID, PaymentDetails, true),
    !.
s3306_b_exception_applies(_CaseID, _EmployerID, _EmployeeID, _CalendarYear, _PaymentAmount, PaymentDetails, true) :- % (11) Non-cash for agricultural labor
    PaymentDetails = payment(non_cash, _, agricultural_labor_service), % payment(Type, Amount, ServiceNature)
    !.
s3306_b_exception_applies(_CaseID, _EmployerID, _EmployeeID, CalendarYear, _PaymentAmount, PaymentDetails, true) :- % (15) Payment to survivor after death year
    PaymentDetails = payment_to_survivor_after_death_year(EmployeeID, PaymentYear),
    PaymentYear > CalendarYear, % Assuming CalendarYear is year of death for EmployeeID context
    !.
s3306_b_exception_applies(_, _, _, _, _, _, false).
% s3306_b_1_wage_cap_exceeded(CaseID, EmployerID, EmployeeID, CalendarYear, CurrentPaymentAmount, ExceededBool)
s3306_b_1_wage_cap_exceeded(CaseID, EmployerID, EmployeeID, CalendarYear, CurrentPaymentAmount, true) :-
    FUTAWageBase = 7000,
    fact(CaseID, ytd_futa_wages_paid_to_employee(EmployerID, EmployeeID, CalendarYear, YTDPaidWages)), % Before this payment
    TotalConsideringCurrent is YTDPaidWages + CurrentPaymentAmount,
    YTDPaidWages >= FUTAWageBase, % Already at or over cap before this payment
    !.
s3306_b_1_wage_cap_exceeded(CaseID, EmployerID, EmployeeID, CalendarYear, CurrentPaymentAmount, true) :-
    FUTAWageBase = 7000,
    fact(CaseID, ytd_futa_wages_paid_to_employee(EmployerID, EmployeeID, CalendarYear, YTDPaidWages)),
    TotalConsideringCurrent is YTDPaidWages + CurrentPaymentAmount,
    YTDPaidWages < FUTAWageBase, TotalConsideringCurrent > FUTAWageBase, % This payment crosses the cap
    PortionOverCap is TotalConsideringCurrent - FUTAWageBase,
    PortionOverCap >= CurrentPaymentAmount, % The current payment is entirely over cap (this logic is tricky)
                                       % The rule is "that part of remuneration which ... is paid" AFTER $7000 has been paid.
                                       % So, if YTD is $6000, and current payment is $1500, then $500 is excluded.
                                       % This predicate should check if the CurrentPaymentAmount ITSELF is part of the excess.
                                       % This requires knowing how much of CurrentPaymentAmount is taxable.
                                       % Simpler: this predicate is about the *portion* of the payment.
                                       % Let's assume s3306_b_total_futa_wages_for_employer handles the capping.
                                       % This s3306_b_is_futa_wage is for a *specific* payment amount.
                                       % If CurrentPaymentAmount itself is the part *after* $7000, then true.
    AmountTaxable is FUTAWageBase - YTDPaidWages,
    (AmountTaxable < 0, ExceededBool = true ; % Already over limit, current payment is excess
     CurrentPaymentAmount > AmountTaxable, ExceededBool = true % Part of current payment is excess
    ), !.
s3306_b_1_wage_cap_exceeded(_, _, _, _, _, false).
% s3306_b_2_plan_payment_exception(CaseID, PaymentDetails, AppliesBool)
s3306_b_2_plan_payment_exception(_CaseID, PaymentDetails, true) :-
    PaymentDetails = plan_payment_sickness_disability_death(_PlanType), % e.g. employer_plan_general_employees
    % Needs more detail on plan qualification if tested.
    !.
s3306_b_2_plan_payment_exception(_, _, false).
% s3306_b_7_non_business_cash_remuneration_exception_applies(CaseID, EmployerID, EmployeeID, PaymentDetails, AppliesBool)
% "remuneration paid in any medium other than cash to an employee for service not in the course of the employer's trade or business"
s3306_b_7_non_business_cash_remuneration_exception_applies(_CaseID, _EmployerID, _EmployeeID, PaymentDetails, true) :-
    PaymentDetails = payment(non_cash, _Amount, service_not_in_course_of_business),
    !.
s3306_b_7_non_business_cash_remuneration_exception_applies(_, _, _, _, false).
% s3306_b_10_termination_payment_exception(CaseID, EmployerID, EmployeeID, PaymentDetails, AppliesBool)
s3306_b_10_termination_payment_exception(CaseID, EmployerID, EmployeeID, PaymentDetails, true) :-
    s3306_b_10_A_termination_payment_exception_applies(CaseID, EmployerID, EmployeeID, PaymentDetails, true),
    PaymentDetails = termination_payment(_, PlanDetails, _), % PlanDetails needs to be checked per (B)
    fact(CaseID, payment_under_employer_plan(EmployerID, PlanDetails)), % Plan established by employer for employees generally
    fact(CaseID, payment_would_not_have_been_made_if_not_terminated(EmployerID, EmployeeID, PaymentDetails)),
    !.
s3306_b_10_termination_payment_exception(_, _, _, _, false).
% s3306_b_10_A_termination_payment_exception_applies(CaseID, EmployerID, EmployeeID, PaymentDetails, AppliesBool)
% "upon or after the termination ... because of (i) death, or (ii) retirement for disability"
s3306_b_10_A_termination_payment_exception_applies(_CaseID, _EmployerID, _EmployeeID, PaymentDetails, true) :-
    PaymentDetails = termination_payment(Reason, _, _Amount), % termination_payment(reason_atom, plan_details, amount)
    (Reason == death ; Reason == retirement_for_disability),
    !.
s3306_b_10_A_termination_payment_exception_applies(_, _, _, _, false).
% s3306_b_total_futa_wages_for_employer(CaseID, EmployerID, CalendarYear, TotalFUTAWages)
% Sums all FUTA wages for an employer, respecting the $7000 cap per employee.
s3306_b_total_futa_wages_for_employer(CaseID, EmployerID, CalendarYear, TotalFUTAWages) :-
    FUTAWageBaseCap = 7000,
    findall(EmployeeID, fact(CaseID, paid_remuneration_to_employee(EmployerID, EmployeeID, CalendarYear, _, _)), AllEmployeesList),
    list_to_set(AllEmployeesList, UniqueEmployees), % Get unique employees for the employer in the year
    s3306_b_sum_capped_wages_for_employees(CaseID, EmployerID, CalendarYear, UniqueEmployees, FUTAWageBaseCap, 0, TotalFUTAWages).
s3306_b_sum_capped_wages_for_employees(_CaseID, _EmployerID, _CalendarYear, [], _Cap, Acc, Acc).
s3306_b_sum_capped_wages_for_employees(CaseID, EmployerID, CalendarYear, [EmployeeID | RestEmployees], Cap, AccIn, AccOut) :-
    findall(PaymentAmount,
            ( fact(CaseID, paid_remuneration_to_employee(EmployerID, EmployeeID, CalendarYear, PaymentAmount, PaymentDetails)),
              s3306_b_is_futa_wage(CaseID, EmployerID, EmployeeID, CalendarYear, PaymentAmount, PaymentDetails, true) % Check if this specific payment is a FUTA wage
            ), EmployeePayments),
    sum_list(EmployeePayments, TotalWagesForEmployeeUncapped),
    CappedEmployeeWages is min(TotalWagesForEmployeeUncapped, Cap),
    NewAcc is AccIn + CappedEmployeeWages,
    s3306_b_sum_capped_wages_for_employees(CaseID, EmployerID, CalendarYear, RestEmployees, Cap, NewAcc, AccOut).
% s3306_c_is_employment(CaseID, EmployerID, EmployeeID, ServiceDetails, IsEmploymentBool)
% Determines if a service constitutes "employment". ServiceDetails is a term describing the service.
s3306_c_is_employment(CaseID, EmployerID, EmployeeID, ServiceDetails, true) :-
    ServiceDetails = service_details(Nature, Location, Citizenship), % e.g. service_details(general_work, usa, us_citizen)
    % General rule: service by employee for employer
    ( (Location == usa) % (A) Performed within the United States
    ; (Location == outside_usa, Citizenship == us_citizen, fact(CaseID, is_american_employer(EmployerID))) % (B) Outside US by US citizen for American employer
      % Add exclusion for contiguous country with agreement if needed
    ),
    \+ s3306_c_exception_applies(CaseID, EmployerID, EmployeeID, ServiceDetails, true),
    !.
s3306_c_is_employment(_, _, _, _, false).
% s3306_c_exception_applies(CaseID, EmployerID, EmployeeID, ServiceDetails, ExceptionAppliesBool)
s3306_c_exception_applies(CaseID, EmployerID, _EmployeeID, ServiceDetails, true) :- % (1) Agricultural labor exception
    ServiceDetails = service_details(agricultural_labor, _, _),
    \+ s3306_c_1_agricultural_labor_is_employment(CaseID, EmployerID, ServiceDetails, true), % Exception applies if it's NOT employment under c(1)
    !.
s3306_c_exception_applies(CaseID, EmployerID, _EmployeeID, ServiceDetails, true) :- % (2) Domestic service exception
    ServiceDetails = service_details(domestic_service, _, _),
    \+ s3306_c_2_domestic_service_is_employment(CaseID, EmployerID, ServiceDetails, true), % Exception applies if it's NOT employment under c(2)
    !.
s3306_c_exception_applies(CaseID, EmployerID, EmployeeID, _ServiceDetails, true) :- % (5) Family employment
    s3306_c_5_family_employment_exception_applies(CaseID, EmployerID, EmployeeID, _CalendarYearFromServiceDetails, true), % Need CalendarYear
    !.
s3306_c_exception_applies(_CaseID, _EmployerID, _EmployeeID, ServiceDetails, true) :- % (6) US Government
    ServiceDetails = service_details(us_government_service, _, _),
    !.
s3306_c_exception_applies(_CaseID, _EmployerID, _EmployeeID, ServiceDetails, true) :- % (7) State/local Government
    ServiceDetails = service_details(state_local_government_service, _, _),
    !.
s3306_c_exception_applies(_CaseID, _EmployerID, EmployeeID, ServiceDetails, true) :- % (10) Student/spouse at school, patient at hospital
    s3306_c_10_school_hospital_service_exception(CaseID, EmployeeID, ServiceDetails, true),
    !.
s3306_c_exception_applies(_CaseID, _EmployerID, _EmployeeID, ServiceDetails, true) :- % (11) Foreign government
    ServiceDetails = service_details(foreign_government_service, _, _),
    !.
s3306_c_exception_applies(_CaseID, _EmployerID, EmployeeID, ServiceDetails, true) :- % (13) Student nurse
    ServiceDetails = service_details(student_nurse_service, _, _), % EmployeeID is the student nurse
    fact(_CaseID, is_student_nurse_enrolled_attending(EmployeeID, _HospitalOrSchool)),
    !.
s3306_c_exception_applies(_CaseID, _EmployerID, _EmployeeID, ServiceDetails, true) :- % (16) International organization
    ServiceDetails = service_details(international_organization_service, _, _),
    !.
s3306_c_exception_applies(_CaseID, _EmployerID, EmployeeID, ServiceDetails, true) :- % (21) Penal institution
    ServiceDetails = service_details(penal_institution_inmate_service, _, _), % EmployeeID is inmate
    fact(_CaseID, is_committed_to_penal_institution(EmployeeID)),
    !.
s3306_c_exception_applies(_, _, _, _, false).
% s3306_c_1_agricultural_labor_is_employment(CaseID, PersonWhoPays, ServiceDetails, IsEmploymentBool)
% Agricultural labor IS employment if conditions (A) and (B) are met.
s3306_c_1_agricultural_labor_is_employment(CaseID, PersonWhoPays, ServiceDetails, true) :-
    ServiceDetails = service_details(agricultural_labor, _, _),
    s3306_c_1_A_agri_employer_wage_or_employee_test(CaseID, PersonWhoPays, _CalendarYearFromService, true), % Need year
    \+ s3306_c_1_B_agri_labor_by_certain_alien(CaseID, _EmployeeIDFromService, true), % Need employee
    !.
s3306_c_1_agricultural_labor_is_employment(_, _, _, false).
% s3306_c_1_A_agri_employer_wage_or_employee_test(CaseID, PersonWhoPays, CalendarYear, MetBool)
% (i) cash remuneration of $20,000 or more OR (ii) 10 days with 5+ employees
s3306_c_1_A_agri_employer_wage_or_employee_test(CaseID, PersonWhoPays, CalendarYear, true) :-
    YearToCheck = CalendarYear ; YearToCheck is CalendarYear - 1,
    (   fact(CaseID, paid_cash_remuneration_agri_labor(PersonWhoPays, YearToCheck, Amount)), Amount >= 20000
    ;   fact(CaseID, employed_agri_labor_days_5_or_more_employees(PersonWhoPays, YearToCheck, NumDays)), NumDays >= 10
    ), !.
s3306_c_1_A_agri_employer_wage_or_employee_test(_, _, _, false).
% s3306_c_1_B_agri_labor_by_certain_alien(CaseID, EmployeeID, IsCertainAlienBool)
s3306_c_1_B_agri_labor_by_certain_alien(CaseID, EmployeeID, true) :-
    fact(CaseID, is_alien_admitted_for_agri_labor_h2a(EmployeeID)), % H-2A visa holder etc.
    !.
s3306_c_1_B_agri_labor_by_certain_alien(_, _, false).
% s3306_c_2_domestic_service_is_employment(CaseID, PersonWhoPays, ServiceDetails, IsEmploymentBool)
% Domestic service IS employment if cash remuneration of $1000 or more.
s3306_c_2_domestic_service_is_employment(CaseID, PersonWhoPays, ServiceDetails, true) :-
    ServiceDetails = service_details(domestic_service, _, _),
    % CalendarYear should be part of ServiceDetails or passed in
    fact(CaseID, service_calendar_year(ServiceDetails, CalendarYear)),
    YearToCheck = CalendarYear ; YearToCheck is CalendarYear - 1,
    fact(CaseID, paid_cash_remuneration_domestic_service_to_individuals(PersonWhoPays, YearToCheck, Amount)),
    Amount >= 1000,
    !.
s3306_c_2_domestic_service_is_employment(_, _, _, false).
% s3306_c_5_family_employment_exception_applies(CaseID, EmployerID, EmployeeID, CalendarYear, AppliesBool)
s3306_c_5_family_employment_exception_applies(CaseID, EmployerID, EmployeeID, _CalendarYear, true) :- % (A) Service for son, daughter, or spouse
    ( fact(CaseID, relationship_child_of(EmployerID, EmployeeID)) % Employer is child of Employee
    ; fact(CaseID, relationship_parent_of(EmployeeID, EmployerID)) % Employee is parent of Employer (same as above)
    ; fact(CaseID, spouse_of(EmployerID, EmployeeID))
    ), !.
s3306_c_5_family_employment_exception_applies(CaseID, EmployerID, EmployeeID, CalendarYear, true) :- % (B) Service by child under 21 for parent
    fact(CaseID, relationship_child_of(EmployeeID, EmployerID)), % Employee is child of Employer
    get_age_at_year_end(CaseID, EmployeeID, CalendarYear, Age),
    Age < 21,
    !.
s3306_c_5_family_employment_exception_applies(_, _, _, _, false).
% s3306_c_10_school_hospital_service_exception(CaseID, EmployeeID, ServiceDetails, AppliesBool)
s3306_c_10_school_hospital_service_exception(CaseID, EmployeeID, ServiceDetails, true) :- % (A)(i) Student at school
    ServiceDetails = service_details(service_for_school_college_university, _, _),
    fact(CaseID, is_student_enrolled_attending(EmployeeID, _SchoolName)), % Employee is student
    !.
s3306_c_10_school_hospital_service_exception(CaseID, EmployeeID, ServiceDetails, true) :- % (A)(ii) Spouse of student
    ServiceDetails = service_details(service_for_school_college_university, _, _),
    fact(CaseID, spouse_of(EmployeeID, StudentSpouseID)),
    fact(CaseID, is_student_enrolled_attending(StudentSpouseID, _SchoolName)),
    % Additional conditions for spouse (e.g., if student's service also covered) - text is minimal here
    !.
s3306_c_10_school_hospital_service_exception(_CaseID, EmployeeID, ServiceDetails, true) :- % (B) Patient at hospital
    ServiceDetails = service_details(service_for_hospital, _, _),
    fact(_CaseID, is_patient_of_hospital(EmployeeID, _HospitalName)), % Employee is patient
    !.
s3306_c_10_school_hospital_service_exception(_, _, _, false).