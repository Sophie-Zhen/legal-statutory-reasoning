:- module(section152,
          [ is_dependent/4,
            is_qualifying_child/4,
            is_qualifying_relative/4,
            is_qualifying_child_relationship/3,
            is_qualifying_relative_relationship/3,
            passes_qc_joint_return_test/4
          ]).

:- use_module(section7703, [is_married/3]).
:- use_module(helpers, [get_age_at_year_end/3]).

:- multifile fact/2.

/*
    §152. Dependent defined
    This module defines who qualifies as a "dependent" for tax purposes,
    distinguishing between a "qualifying child" and a "qualifying relative".
*/

% is_dependent(CaseID, Taxpayer, PotentialDependent, Year)
% §152(a) A dependent is a qualifying child or a qualifying relative.
is_dependent(CaseID, Taxpayer, PotentialDependent, Year) :-
    (   is_qualifying_child(CaseID, Taxpayer, PotentialDependent, Year)
    ;   is_qualifying_relative(CaseID, Taxpayer, PotentialDependent, Year)
    ),
    \+ dependent_exceptions_apply(CaseID, Taxpayer, PotentialDependent, Year).

% dependent_exceptions_apply(CaseID, Taxpayer, PotentialDependent, Year)
% §152(b) Exceptions for dependents.
dependent_exceptions_apply(CaseID, _Taxpayer, PotentialDependent, Year) :-
    % §152(b)(1) Dependent cannot have their own dependents.
    fact(CaseID, dependent(PotentialDependent, _OwnDependent, Year)).
dependent_exceptions_apply(CaseID, _Taxpayer, PotentialDependent, Year) :-
    % §152(b)(2) Married dependent filing a joint return.
    fact(CaseID, files_joint_return(PotentialDependent, _Spouse, Year)).

% is_qualifying_child(CaseID, Taxpayer, Individual, Year)
% §152(c)(1) In general
is_qualifying_child(CaseID, Taxpayer, Individual, Year) :-
    is_qualifying_child_relationship(CaseID, Taxpayer, Individual),
    has_same_principal_abode_more_than_half_year(CaseID, Taxpayer, Individual, Year),
    meets_qc_age_requirements(CaseID, Taxpayer, Individual, Year),
    passes_qc_joint_return_test(CaseID, Individual, Taxpayer, Year).

% is_qualifying_child_relationship(CaseID, Taxpayer, Individual)
% §152(c)(2) Relationship test for qualifying child.
is_qualifying_child_relationship(CaseID, Taxpayer, Individual) :-
    fact(CaseID, child_of(Individual, Taxpayer)).
is_qualifying_child_relationship(CaseID, Taxpayer, Individual) :-
    fact(CaseID, child_of(Individual, ChildOfTaxpayer)),
    fact(CaseID, child_of(ChildOfTaxpayer, Taxpayer)). % Descendant
is_qualifying_child_relationship(CaseID, Taxpayer, Individual) :-
    fact(CaseID, sibling_of(Individual, Taxpayer)).
is_qualifying_child_relationship(CaseID, Taxpayer, Individual) :-
    fact(CaseID, child_of(Individual, SiblingOfTaxpayer)),
    fact(CaseID, sibling_of(SiblingOfTaxpayer, Taxpayer)). % Descendant of sibling

% has_same_principal_abode_more_than_half_year(CaseID, Taxpayer, Individual, Year)
% §152(c)(1)(B) Principal place of abode test.
has_same_principal_abode_more_than_half_year(CaseID, Taxpayer, Individual, Year) :-
    fact(CaseID, lived_together_more_than_half_year(Individual, Taxpayer, Year)).

% meets_qc_age_requirements(CaseID, Taxpayer, Individual, Year)
% §152(c)(3) Age requirements for qualifying child.
meets_qc_age_requirements(CaseID, Taxpayer, Individual, Year) :-
    fact(CaseID, date_of_birth(Individual, DOB_Ind)),
    fact(CaseID, date_of_birth(Taxpayer, DOB_Tax)),
    get_age_at_year_end(DOB_Ind, Year, Age_Ind),
    get_age_at_year_end(DOB_Tax, Year, Age_Tax),
    Age_Ind < Age_Tax,
    Age_Ind < 25.

% passes_qc_joint_return_test(CaseID, Individual, Taxpayer, Year)
% §152(c)(1)(E) Joint return test.
passes_qc_joint_return_test(CaseID, Individual, _Taxpayer, Year) :-
    % Individual has not filed a joint return.
    \+ fact(CaseID, files_joint_return(Individual, _, Year)).
passes_qc_joint_return_test(CaseID, Individual, _Taxpayer, Year) :-
    % Exception: filed only for a claim of refund.
    fact(CaseID, files_joint_return_for_refund_only(Individual, _, Year)).

% is_qualifying_relative(CaseID, Taxpayer, Individual, Year)
% §152(d)(1) In general
is_qualifying_relative(CaseID, Taxpayer, Individual, Year) :-
    is_qualifying_relative_relationship(CaseID, Taxpayer, Individual),
    has_no_income(CaseID, Individual, Year),
    is_not_a_qualifying_child_of_any_taxpayer(CaseID, Individual, Year).

% is_qualifying_relative_relationship(CaseID, Taxpayer, Individual)
% §152(d)(2) Relationship test for qualifying relative.
is_qualifying_relative_relationship(CaseID, Taxpayer, Individual) :- is_qualifying_child_relationship(CaseID, Taxpayer, Individual). % (A), (B)
is_qualifying_relative_relationship(CaseID, Taxpayer, Individual) :- fact(CaseID, parent_of(Individual, Taxpayer)). % (C)
is_qualifying_relative_relationship(CaseID, Taxpayer, Individual) :- fact(CaseID, parent_of(Ancestor, Taxpayer)), fact(CaseID, parent_of(Individual, Ancestor)). % (C)
is_qualifying_relative_relationship(CaseID, Taxpayer, Individual) :- fact(CaseID, stepparent_of(Individual, Taxpayer)). % (D)
is_qualifying_relative_relationship(CaseID, Taxpayer, Individual) :- fact(CaseID, child_of(Individual, Sibling)), fact(CaseID, sibling_of(Sibling, Taxpayer)). % (E) Nephew/Niece
is_qualifying_relative_relationship(CaseID, Taxpayer, Individual) :- fact(CaseID, parent_of(Parent, Taxpayer)), fact(CaseID, sibling_of(Individual, Parent)). % (F) Uncle/Aunt
is_qualifying_relative_relationship(CaseID, Taxpayer, Individual) :- fact(CaseID, in_law_of(Individual, Taxpayer, _)). % (G)
is_qualifying_relative_relationship(CaseID, Taxpayer, Individual) :- % (H)
    fact(CaseID, member_of_household(Individual, Taxpayer, _Year)),
    \+ is_married(CaseID, Individual, _Year).

% has_no_income(CaseID, Individual, Year)
% §152(d)(1)(B) Gross income test.
has_no_income(CaseID, Individual, Year) :-
    fact(CaseID, gross_income(Individual, Year, Amount)),
    Amount =:= 0.
has_no_income(CaseID, Individual, Year) :-
    \+ fact(CaseID, gross_income(Individual, Year, _)).

% is_not_a_qualifying_child_of_any_taxpayer(CaseID, Individual, Year)
% §152(d)(1)(D) Not a qualifying child test.
is_not_a_qualifying_child_of_any_taxpayer(CaseID, Individual, Year) :-
    \+ is_qualifying_child(CaseID, _AnyTaxpayer, Individual, Year).
