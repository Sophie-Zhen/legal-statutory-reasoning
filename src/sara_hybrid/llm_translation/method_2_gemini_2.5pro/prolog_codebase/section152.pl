:- module(section152,
          [ is_dependent/4,                   % is_dependent(Taxpayer, PotentialDependent, CaseID, Year)
            is_qualifying_child/4,            % is_qualifying_child(Taxpayer, PotentialChild, CaseID, Year)
            is_qualifying_relative/4,         % is_qualifying_relative(Taxpayer, PotentialRelative, CaseID, Year)
            relationship_qualifying_child/3,  % relationship_qualifying_child(Taxpayer, PotentialChild, CaseID)
            relationship_qualifying_relative/3% relationship_qualifying_relative(Taxpayer, PotentialRelative, CaseID)
          ]).

:- use_module(tests, [fact/2]).
:- use_module(helpers, [calculate_age_at_year_end/3]).
:- use_module(section7703, [is_married_a/3]). % For (d)(2)(H)

% §152(a) In general, a dependent is a qualifying child or qualifying relative.
is_dependent(Taxpayer, PotentialDependent, CaseID, Year) :-
    \+ is_dependent_ineligible(Taxpayer, PotentialDependent, CaseID, Year),
    (   is_qualifying_child(Taxpayer, PotentialDependent, CaseID, Year)
    ;   is_qualifying_relative(Taxpayer, PotentialDependent, CaseID, Year)
    ).

% §152(b) Exceptions
is_dependent_ineligible(_Taxpayer, PotentialDependent, CaseID, Year) :-
    % (b)(2) An individual shall not be treated as a dependent if they file a joint return.
    fact(CaseID, spouse(PotentialDependent, Spouse)),
    fact(CaseID, files_joint_return(PotentialDependent, Spouse, Year)),
    % Exception: unless filed only for a claim of refund (not modeled from facts).
    !.
is_dependent_ineligible(Taxpayer, PotentialDependent, CaseID, Year) :-
    % (b)(1) If an individual is a dependent of another taxpayer, they can't have dependents.
    % This means we cannot find someone for whom PotentialDependent is a dependent.
    % This is a global property. To avoid infinite loops, we assume facts about
    % who is a dependent of whom are either given or not.
    fact(CaseID, is_dependent_of(PotentialDependent, OtherTaxpayer, Year)),
    Taxpayer \== OtherTaxpayer.


% §152(c) Qualifying child
is_qualifying_child(Taxpayer, PotentialChild, CaseID, Year) :-
    % (c)(1) In general
    % (A) Relationship
    relationship_qualifying_child(Taxpayer, PotentialChild, CaseID),
    % (B) Abode
    fact(CaseID, lived_with_over_half_year(PotentialChild, Taxpayer, Year)),
    % (C) Age
    fact(CaseID, birth_year(PotentialChild, ChildBirthYear)),
    fact(CaseID, birth_year(Taxpayer, TaxpayerBirthYear)),
    calculate_age_at_year_end(ChildBirthYear, Year, ChildAge),
    calculate_age_at_year_end(TaxpayerBirthYear, Year, TaxpayerAge),
    ChildAge < TaxpayerAge,
    ChildAge < 25, % Simplified from text "is less than 25 years old at the end of the taxable year"
    % (E) Has not filed a joint return
    \+ (
        fact(CaseID, spouse(PotentialChild, Spouse)),
        fact(CaseID, files_joint_return(PotentialChild, Spouse, Year))
    ).

% §152(c)(2) Relationship for Qualifying Child
relationship_qualifying_child(Taxpayer, Potential, CaseID) :-
    child_or_descendant(Potential, Taxpayer, CaseID).
relationship_qualifying_child(Taxpayer, Potential, CaseID) :-
    sibling_or_descendant(Potential, Taxpayer, CaseID).


% §152(d) Qualifying relative
is_qualifying_relative(Taxpayer, PotentialRelative, CaseID, Year) :-
    % (d)(1) In general
    % (A) Relationship
    relationship_qualifying_relative(Taxpayer, PotentialRelative, CaseID),
    % (B) No income (as per statute text)
    \+ (fact(CaseID, gross_income(PotentialRelative, Year, Income)), Income > 0),
    % (D) Not a qualifying child of any taxpayer
    \+ is_qualifying_child_of_any_taxpayer(PotentialRelative, CaseID, Year).

% Helper for §152(d)(1)(D)
is_qualifying_child_of_any_taxpayer(Person, CaseID, Year) :-
    % This checks if there exists *any* taxpayer in the fact base for whom this person is a QC.
    fact(CaseID, taxpayer(AnyTaxpayer)),
    AnyTaxpayer \== Person,
    is_qualifying_child(AnyTaxpayer, Person, CaseID, Year).


% §152(d)(2) Relationship for Qualifying Relative
relationship_qualifying_relative(Taxpayer, Potential, CaseID) :-
    child_or_descendant(Potential, Taxpayer, CaseID).
relationship_qualifying_relative(Taxpayer, Potential, CaseID) :-
    sibling(Potential, Taxpayer, CaseID).
relationship_qualifying_relative(Taxpayer, Potential, CaseID) :-
    stepbrother_or_stepsister(Potential, Taxpayer, CaseID).
relationship_qualifying_relative(Taxpayer, Potential, CaseID) :-
    parent_or_ancestor(Potential, Taxpayer, CaseID).
relationship_qualifying_relative(Taxpayer, Potential, CaseID) :-
    stepparent(Potential, Taxpayer, CaseID).
relationship_qualifying_relative(Taxpayer, Potential, CaseID) :-
    child_of_sibling(Potential, Taxpayer, CaseID). % Niece/Nephew
relationship_qualifying_relative(Taxpayer, Potential, CaseID) :-
    sibling_of_parent(Potential, Taxpayer, CaseID). % Aunt/Uncle
relationship_qualifying_relative(Taxpayer, Potential, CaseID) :-
    in_law(Potential, Taxpayer, CaseID).
relationship_qualifying_relative(Taxpayer, Potential, CaseID) :-
    % (H) Member of taxpayer's household
    \+ is_married_a(Taxpayer, CaseID, _), % Not spouse, at any time during year.
    fact(CaseID, same_principal_place_of_abode(Potential, Taxpayer, Year)),
    fact(CaseID, member_of_household(Potential, Taxpayer, Year)).


% --- Relationship Helpers ---
% Using a simple fact-based representation.
parent_of(Parent, Child, CaseID) :- fact(CaseID, child_of(Child, Parent)).
child_or_descendant(Desc, Ance, CaseID) :- parent_of(Ance, Desc, CaseID).
child_or_descendant(Desc, Ance, CaseID) :- parent_of(Ance, Mid, CaseID), child_or_descendant(Desc, Mid, CaseID).

sibling(S1, S2, CaseID) :- parent_of(P, S1, CaseID), parent_of(P, S2, CaseID), S1 \== S2.
sibling_or_descendant(Person, Taxpayer, CaseID) :- sibling(Person, Taxpayer, CaseID).
sibling_or_descendant(Person, Taxpayer, CaseID) :-
    sibling(Sib, Taxpayer, CaseID), child_or_descendant(Person, Sib, CaseID).
sibling_or_descendant(Person, Taxpayer, CaseID) :-
    stepbrother_or_stepsister(Person, Taxpayer, CaseID).
sibling_or_descendant(Person, Taxpayer, CaseID) :-
    stepbrother_or_stepsister(Sib, Taxpayer, CaseID), child_or_descendant(Person, Sib, CaseID).

stepbrother_or_stepsister(S1, S2, CaseID) :- fact(CaseID, stepbrother_of(S1, S2)); fact(CaseID, stepsister_of(S1, S2)).

parent_or_ancestor(Ance, Desc, CaseID) :- parent_of(Ance, Desc, CaseID).
parent_or_ancestor(Ance, Desc, CaseID) :- parent_of(Mid, Desc, CaseID), parent_or_ancestor(Ance, Mid, CaseID).

stepparent(SP, SC, CaseID) :- fact(CaseID, stepparent_of(SP, SC)).
child_of_sibling(Person, Taxpayer, CaseID) :-
    sibling(Sib, Taxpayer, CaseID),
    parent_of(Sib, Person, CaseID).
sibling_of_parent(Person, Taxpayer, CaseID) :-
    parent_of(P, Taxpayer, CaseID),
    sibling(Person, P, CaseID).

in_law(Rel, Taxpayer, CaseID) :- fact(CaseID, spouse(Taxpayer, Spouse)), parent_of(Rel, Spouse, CaseID). % parent-in-law
in_law(Rel, Taxpayer, CaseID) :- fact(CaseID, spouse(Taxpayer, Spouse)), sibling(Rel, Spouse, CaseID). % sibling-in-law
in_law(Rel, Taxpayer, CaseID) :- child_of_sibling(C, Taxpayer, CaseID), fact(CaseID, spouse(Rel, C)). % son/daughter-in-law
