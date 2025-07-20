:- module(section7703,
    [
        is_married/4,
        is_not_considered_married_living_apart/4
    ]).

:- use_module(section151, [is_entitled_to_deduction/4]).
:- use_module(library(lists), [member/2]).

:- multifile fact/2.

is_married(CaseID, Taxpayer, Year, not_married) :-
    fact(CaseID, legally_separated(Taxpayer, _, Year, _)),
    !.
is_married(CaseID, Taxpayer, Year, not_married) :-
    fact(CaseID, legally_separated(_, Taxpayer, Year, _)),
    !.
is_married(CaseID, Taxpayer, Year, not_married) :-
    is_not_considered_married_living_apart(CaseID, Taxpayer, Year, true),
    !.
is_married(CaseID, Taxpayer, Year, Status) :-
    (fact(CaseID, married(Taxpayer, Spouse, StartDate)) ; fact(CaseID, married(Spouse, Taxpayer, StartDate))),
    fact(CaseID, date(StartDate, SY, _, _)),
    SY =< Year,
    (   fact(CaseID, died(Spouse, Year, _)) -> Status = married
    ;   fact(CaseID, died(Spouse, DeathYear, _)), DeathYear < Year -> Status = not_married
    ;   Status = married
    ), !.
is_married(_CaseID, _Taxpayer, _Year, not_married).

is_not_considered_married_living_apart(CaseID, Taxpayer, Year, true) :-
    is_married_under_a(CaseID, Taxpayer, Year),
    fact(CaseID, files_separate_return(Taxpayer, Year)),
    fact(CaseID, maintains_household_for_child_gt_half_year(Taxpayer, Child, Year)),
    is_entitled_to_deduction(CaseID, Taxpayer, Child, Year),
    fact(CaseID, furnished_over_half_cost_of_household(Taxpayer, Year)),
    fact(CaseID, spouse_not_in_household_last_6_months(Taxpayer, Year)),
    !.
is_not_considered_married_living_apart(_CaseID, _Taxpayer, _Year, false).

is_married_under_a(CaseID, Taxpayer, Year) :-
    \+ (fact(CaseID, legally_separated(Taxpayer, _, Year, _)); fact(CaseID, legally_separated(_, Taxpayer, Year, _))),
    (fact(CaseID, married(Taxpayer, Spouse, StartDate)) ; fact(CaseID, married(Spouse, Taxpayer, StartDate))),
    fact(CaseID, date(StartDate, SY, _, _)),
    SY =< Year,
    \+ (fact(CaseID, died(Spouse, DeathYear, _)), DeathYear < Year).
