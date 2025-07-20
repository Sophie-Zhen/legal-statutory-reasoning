:- module(section152,
    [
        is_dependent/4,
        is_qualifying_child/4,
        is_qualifying_relative/4,
        relationship_qualifying_child/3,
        relationship_qualifying_relative/3,
        qualifying_child_no_joint_return/3
    ]).

:- use_module(section7703, [is_married/4]).
:- use_module(helpers, [get_age_at_year_end/3]).
:- use_module(library(lists), [member/2]).

:- multifile fact/2.

is_dependent(CaseID, Taxpayer, PotentialDependent, Year) :-
    \+ exception_b1_dependent_ineligible(CaseID, PotentialDependent, Year),
    \+ exception_b2_married_dependent(CaseID, PotentialDependent, Year),
    (   is_qualifying_child(CaseID, Taxpayer, PotentialDependent, Year)
    ;   is_qualifying_relative(CaseID, Taxpayer, PotentialDependent, Year)
    ).

exception_b1_dependent_ineligible(CaseID, Taxpayer, Year) :-
    fact(CaseID, is_dependent_of(Taxpayer, _OtherTaxpayer, Year)).

exception_b2_married_dependent(CaseID, PotentialDependent, Year) :-
    fact(CaseID, files_joint_return(PotentialDependent, _Spouse, Year)).

is_qualifying_child(CaseID, Taxpayer, PotentialQC, Year) :-
    relationship_qualifying_child(CaseID, Taxpayer, PotentialQC),
    fact(CaseID, principal_place_of_abode_for_more_than_half_year(PotentialQC, Taxpayer, Year)),
    age_requirement_qualifying_child(CaseID, Taxpayer, PotentialQC, Year),
    qualifying_child_no_joint_return(PotentialQC, Year, CaseID).

is_qualifying_relative(CaseID, Taxpayer, PotentialQR, Year) :-
    relationship_qualifying_relative(CaseID, Taxpayer, PotentialQR),
    \+ (fact(CaseID, gross_income(PotentialQR, Year, Income)), Income > 0),
    \+ is_qualifying_child(CaseID, Taxpayer, PotentialQR, Year),
    \+ (fact(CaseID, is_qualifying_child_of(PotentialQR, OtherTaxpayer, Year)), OtherTaxpayer \= Taxpayer).

relationship_qualifying_child(CaseID, Taxpayer, Person) :-
    (   child_or_descendant(CaseID, Taxpayer, Person)
    ;   sibling_or_descendant(CaseID, Taxpayer, Person)
    ).

age_requirement_qualifying_child(CaseID, Taxpayer, PotentialQC, Year) :-
    fact(CaseID, date_of_birth(Taxpayer, TaxpayerDOB)),
    fact(CaseID, date_of_birth(PotentialQC, PotentialQCDOB)),
    get_age_at_year_end(TaxpayerDOB, Year, TaxpayerAge),
    get_age_at_year_end(PotentialQCDOB, Year, PotentialQCAge),
    PotentialQCAge < TaxpayerAge,
    PotentialQCAge < 25.

qualifying_child_no_joint_return(Child, Year, CaseID) :-
    \+ fact(CaseID, files_joint_return(Child, _Spouse, Year)).

relationship_qualifying_relative(CaseID, Taxpayer, Person) :-
    member(RelationshipType, [(a), (b), (c), (d), (e), (f), (g), (h)]),
    relationship_qualifying_relative(CaseID, Taxpayer, Person, RelationshipType), !.

relationship_qualifying_relative(CaseID, Taxpayer, Person, (a)) :- child_or_descendant(CaseID, Taxpayer, Person).
relationship_qualifying_relative(CaseID, Taxpayer, Person, (b)) :- sibling_or_descendant(CaseID, Taxpayer, Person).
relationship_qualifying_relative(CaseID, Taxpayer, Person, (c)) :- parent_or_ancestor(CaseID, Taxpayer, Person).
relationship_qualifying_relative(CaseID, Taxpayer, Person, (d)) :- fact(CaseID, step_parent(Person, Taxpayer)).
relationship_qualifying_relative(CaseID, Taxpayer, Person, (e)) :- child_of_sibling(CaseID, Taxpayer, Person).
relationship_qualifying_relative(CaseID, Taxpayer, Person, (f)) :- sibling_of_parent(CaseID, Taxpayer, Person).
relationship_qualifying_relative(CaseID, Taxpayer, Person, (g)) :- in_law(CaseID, Taxpayer, Person).
relationship_qualifying_relative(CaseID, Taxpayer, Person, (h)) :-
    is_married(CaseID, Taxpayer, Year, Status), (Status = not_married ; (fact(CaseID, married(Taxpayer, S, _)), S \= Person)),
    fact(CaseID, principal_place_of_abode_for_full_year(Person, Taxpayer, Year)).

child_or_descendant(CaseID, Parent, Child) :- fact(CaseID, child(Child, Parent)).
child_or_descendant(CaseID, Ancestor, Descendant) :-
    fact(CaseID, child(Descendant, Intermediate)),
    child_or_descendant(CaseID, Ancestor, Intermediate).

sibling_or_descendant(CaseID, Person, Sibling) :- (fact(CaseID, sibling(Sibling, Person)) ; fact(CaseID, sibling(Person, Sibling))).
sibling_or_descendant(CaseID, Person, Descendant) :-
    (fact(CaseID, sibling(Sibling, Person)) ; fact(CaseID, sibling(Person, Sibling))),
    child_or_descendant(CaseID, Sibling, Descendant).

parent_or_ancestor(CaseID, Child, Parent) :- child_or_descendant(CaseID, Parent, Child).
child_of_sibling(CaseID, Person, NieceNephew) :-
    (fact(CaseID, sibling(Sibling, Person)) ; fact(CaseID, sibling(Person, Sibling))),
    fact(CaseID, child(NieceNephew, Sibling)).
sibling_of_parent(CaseID, Person, AuntUncle) :-
    fact(CaseID, child(Person, Parent)),
    (fact(CaseID, sibling(AuntUncle, Parent)) ; fact(CaseID, sibling(Parent, AuntUncle))).
in_law(CaseID, Person, InLaw) :-
    (fact(CaseID, married(Person, Spouse, _)); fact(CaseID, married(Spouse, Person, _))),
    ( fact(CaseID, child(Spouse, InLaw))
    ; fact(CaseID, child(InLaw, Person))
    ; (fact(CaseID, sibling(InLaw, Spouse)) ; fact(CaseID, sibling(Spouse, InLaw)))
    ).
