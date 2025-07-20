:- module(section3306,
    [
        is_employer/4,
        is_employer_general/4,
        is_wages/6,
        is_wages_exception_b7/5,
        is_wages_exception_b10/6,
        is_employment/5,
        is_employment_exception_c5/5
    ]).

:- use_module(knowledge_base).
:- use_module(helpers).
:- multifile fact/2.

is_employer(CaseID, Person, Year, true) :-
    (   is_employer_general(CaseID, Person, Year, true)
    ;   is_employer_agricultural(CaseID, Person, Year, true)
    ;   is_employer_domestic(CaseID, Person, Year, true)
    ), !.
is_employer(_CaseID, _Person, _Year, false).

is_employer_general(CaseID, Person, Year, true) :-
    \+ fact(CaseID, paid_wages(Person, _, _, _, domestic_service)),
    (   paid_wages_over_threshold(CaseID, Person, Year, general)
    ;   employed_enough_individuals(CaseID, Person, Year, general)
    ).

is_wages(CaseID, Payer, Payee, Amount, Year, true) :-
    fact(CaseID, paid_remuneration_for_employment(Payer, Payee, Amount, Year)),
    \+ is_wages_exception(CaseID, Payer, Payee, Amount, Year), !.
is_wages(_,_,_,_,_, false).

is_wages_exception(CaseID, Payer, Payee, Amount, Year) :-
    ( is_wages_exception_b7(CaseID, Payer, Payee, Amount, Year, _)
    ; is_wages_exception_b10(CaseID, Payer, Payee, Amount, Year, _)
    ).
is_wages_exception_b7(_CaseID, Payer, _, _, _, not_cash) :-
    fact(Payer, service_not_in_course_of_business),
    fact(Payer, payment_medium(not_cash)).
is_wages_exception_b10(CaseID, Payer, Payee, _, Year, Reason) :-
    member(Reason, [death, disability_retirement]),
    fact(CaseID, payment_termination_of_employment(Payer, Payee, Year, Reason)),
    fact(CaseID, payment_under_plan(Payer, Year, Reason)).

is_employment(CaseID, Payer, Payee, Year, true) :-
    fact(CaseID, service_performed_in_us(Payee, Payer, Year)),
    \+ is_employment_exception(CaseID, Payer, Payee, Year), !.
is_employment(_,_,_,_, false).

is_employment_exception(CaseID, Payer, Payee, Year) :-
    is_employment_exception_c5(CaseID, Payer, Payee, Year, _).
is_employment_exception_c5(CaseID, Payer, Payee, _Year, son_daughter_spouse) :-
    ( fact(CaseID, child(Payee, Payer)) ; fact(CaseID, married(Payer, Payee, _)) ).
is_employment_exception_c5(CaseID, Payer, Payee, Year, child_under_21) :-
    fact(CaseID, child(Payee, Payer)),
    fact(CaseID, date_of_birth(Payee, DOB)),
    get_age_at_year_end(DOB, Year, Age),
    Age < 21.
