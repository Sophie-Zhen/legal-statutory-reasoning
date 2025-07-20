:- module(section2,
    [
        is_surviving_spouse/3,
        is_head_of_household/3,
        surviving_spouse_limitation_joint_return_possible/4
    ]).

:- use_module(section151, [is_entitled_to_deduction/4]).
:- use_module(section152, [is_dependent/4, is_qualifying_child/4, relationship_qualifying_relative/3]).
:- use_module(section7703, [is_married/4]).

:- multifile fact/2.

is_surviving_spouse(CaseID, Taxpayer, Year) :-
    (fact(CaseID, married(Taxpayer, Spouse, _)); fact(CaseID, married(Spouse, Taxpayer, _))),
    fact(CaseID, died(Spouse, DeathYear, _)),
    (Year - DeathYear =:= 1 ; Year - DeathYear =:= 2),
    fact(CaseID, maintains_household_for_dependent_child(Taxpayer, DependentChild, Year)),
    is_dependent(CaseID, Taxpayer, DependentChild, Year),
    (fact(CaseID, child(DependentChild, Taxpayer)); fact(CaseID, step_child(DependentChild, Taxpayer))),
    is_entitled_to_deduction(CaseID, Taxpayer, DependentChild, Year),
    fact(CaseID, furnished_over_half_cost_of_household(Taxpayer, Year)),
    \+ limitation_remarried(CaseID, Taxpayer, Year),
    surviving_spouse_limitation_joint_return_possible(Taxpayer, Spouse, DeathYear, CaseID).

limitation_remarried(CaseID, Taxpayer, Year) :-
    (fact(CaseID, married(Taxpayer, NewSpouse, RemarriageDate)); fact(CaseID, married(NewSpouse, Taxpayer, RemarriageDate))),
    fact(CaseID, date(RemarriageDate, RY, _, _)),
    RY =< Year,
    fact(CaseID, died(OriginalSpouse, _, _)),
    NewSpouse \= OriginalSpouse.

surviving_spouse_limitation_joint_return_possible(Taxpayer, DeceasedSpouse, YearOfDeath, CaseID) :-
    \+ fact(CaseID, is_nonresident_alien(Taxpayer, YearOfDeath)),
    \+ fact(CaseID, is_nonresident_alien(DeceasedSpouse, YearOfDeath)).

is_head_of_household(CaseID, Taxpayer, Year) :-
    is_married(CaseID, Taxpayer, Year, not_married),
    \+ is_surviving_spouse(CaseID, Taxpayer, Year),
    \+ fact(CaseID, is_nonresident_alien(Taxpayer, Year)),
    (   maintains_household_for_qualifying_person_b1A(CaseID, Taxpayer, Year)
    ;   maintains_household_for_parent_b1B(CaseID, Taxpayer, Year)
    ).

maintains_household_for_qualifying_person_b1A(CaseID, Taxpayer, Year) :-
    fact(CaseID, furnished_over_half_cost_of_household(Taxpayer, Year)),
    fact(CaseID, principal_place_of_abode_for_more_than_half_year(QP, Taxpayer, Year)),
    (   (   is_qualifying_child(CaseID, Taxpayer, QP, Year),
            \+ ( is_married(CaseID, QP, Year, married),
                 \+ qualifying_child_no_joint_return(QP, Year, CaseID)
               )
        )
    ;   (   is_dependent(CaseID, Taxpayer, QP, Year),
            is_entitled_to_deduction(CaseID, Taxpayer, QP, Year),
            \+ relationship_qualifying_relative(CaseID, Taxpayer, QP, (h))
        )
    ).

maintains_household_for_parent_b1B(CaseID, Taxpayer, Year) :-
    fact(CaseID, furnished_over_half_cost_of_household_for_parent(Taxpayer, Year)),
    fact(CaseID, child(Taxpayer, Parent)),
    is_entitled_to_deduction(CaseID, Taxpayer, Parent, Year).
