:- module(section2,
          [ filing_status/4,
            is_surviving_spouse/3,
            is_head_of_household/3
          ]).

:- use_module(section151, [is_entitled_to_exemption_deduction/4]).
:- use_module(section152, [is_dependent/4, is_qualifying_child/4]).
:- use_module(section7703, [is_married/3, is_unmarried/3]).
:- use_module(helpers, [string_to_atom/2]).

:- multifile fact/2.

/*
    §2. Definitions and special rules
    This module defines "surviving spouse" and "head of household" filing statuses.
*/

% filing_status(CaseID, Taxpayer, Year, Status)
% Determines the filing status for a taxpayer. This is the main entry point for other modules.
filing_status(CaseID, Taxpayer, Year, joint) :-
    fact(CaseID, files_joint_return(Taxpayer, _, Year)).
filing_status(CaseID, Taxpayer, Year, married_filing_separately) :-
    is_married(CaseID, Taxpayer, Year),
    fact(CaseID, files_separate_return(Taxpayer, Year)).
filing_status(CaseID, Taxpayer, Year, surviving_spouse) :-
    is_surviving_spouse(CaseID, Taxpayer, Year).
filing_status(CaseID, Taxpayer, Year, head_of_household) :-
    is_head_of_household(CaseID, Taxpayer, Year).
filing_status(CaseID, Taxpayer, Year, single) :-
    is_unmarried(CaseID, Taxpayer, Year),
    \+ is_surviving_spouse(CaseID, Taxpayer, Year),
    \+ is_head_of_household(CaseID, Taxpayer, Year).


% is_surviving_spouse(CaseID, Taxpayer, Year)
% §2(a)(1) Definition of surviving spouse.
is_surviving_spouse(CaseID, Taxpayer, Year) :-
    \+ fact(CaseID, is_nonresident_alien(Taxpayer, Year)),
    spouse_died_in_preceding_two_years(CaseID, Taxpayer, Spouse, Year),
    maintains_home_for_dependent_child(CaseID, Taxpayer, Year),
    \+ has_remarried(CaseID, Taxpayer, Year),
    could_have_filed_joint_return(CaseID, Taxpayer, Spouse, Year - YearsAgo),
    fact(CaseID, died(Spouse, date(DeathYear, _, _))),
    YearsAgo is Year - DeathYear.

% spouse_died_in_preceding_two_years(CaseID, Taxpayer, Spouse, Year)
% §2(a)(1)(A)
spouse_died_in_preceding_two_years(CaseID, Taxpayer, Spouse, Year) :-
    fact(CaseID, spouse_of(Taxpayer, Spouse)),
    fact(CaseID, died(Spouse, date(DeathYear, _, _))),
    Year - DeathYear > 0,
    Year - DeathYear =< 2.

% maintains_home_for_dependent_child(CaseID, Taxpayer, Year)
% §2(a)(1)(B)
maintains_home_for_dependent_child(CaseID, Taxpayer, Year) :-
    fact(CaseID, furnishes_over_half_cost_of_household(Taxpayer, Year)),
    fact(CaseID, child_of(Child, Taxpayer)),
    fact(CaseID, principal_place_of_abode(Child, Taxpayer, Year)),
    is_entitled_to_exemption_deduction(CaseID, Taxpayer, Child, Year, _).

% has_remarried(CaseID, Taxpayer, Year)
% §2(a)(2)(A) Limitation: remarriage.
has_remarried(CaseID, Taxpayer, Year) :-
    fact(CaseID, married(Taxpayer, _NewSpouse, date(RemarryYear, _, _))),
    RemarryYear =< Year.

% could_have_filed_joint_return(CaseID, Taxpayer, DeceasedSpouse, YearOfDeath)
% §2(a)(2)(B) Limitation: eligibility to file joint return in year of death.
could_have_filed_joint_return(_CaseID, Taxpayer, DeceasedSpouse, YearOfDeath) :-
    \+ fact(_CaseID, is_nonresident_alien(Taxpayer, YearOfDeath)),
    \+ fact(_CaseID, is_nonresident_alien(DeceasedSpouse, YearOfDeath)).

% is_head_of_household(CaseID, Taxpayer, Year)
% §2(b)(1) Definition of head of household.
is_head_of_household(CaseID, Taxpayer, Year) :-
    is_unmarried(CaseID, Taxpayer, Year),
    \+ is_surviving_spouse(CaseID, Taxpayer, Year),
    ( maintains_home_for_qualifying_person_A(CaseID, Taxpayer, Year)
    ; maintains_home_for_parent_B(CaseID, Taxpayer, Year)
    ),
    \+ hoh_limitations_apply(CaseID, Taxpayer, Year).

% maintains_home_for_qualifying_person_A(CaseID, Taxpayer, Year)
% §2(b)(1)(A)
maintains_home_for_qualifying_person_A(CaseID, Taxpayer, Year) :-
    fact(CaseID, furnishes_over_half_cost_of_household(Taxpayer, Year)),
    (   % (i) Qualifying child
        is_qualifying_child(CaseID, Taxpayer, Child, Year),
        fact(CaseID, lived_together_more_than_half_year(Child, Taxpayer, Year)),
        \+ (is_married(CaseID, Child, Year),
            \+ is_dependent(CaseID, Taxpayer, Child, Year)) % Negation of §152(b)(2) condition is complex, simplified here.
    ;   % (ii) Other dependent
        is_dependent(CaseID, Taxpayer, Dependent, Year),
        fact(CaseID, lived_together_more_than_half_year(Dependent, Taxpayer, Year)),
        is_entitled_to_exemption_deduction(CaseID, Taxpayer, Dependent, Year, _)
    ).

% maintains_home_for_parent_B(CaseID, Taxpayer, Year)
% §2(b)(1)(B)
maintains_home_for_parent_B(CaseID, Taxpayer, Year) :-
    fact(CaseID, furnishes_over_half_cost_of_household(Taxpayer, Year)), % maintains a household for...
    fact(CaseID, parent_of(Parent, Taxpayer)),
    fact(CaseID, principal_place_of_abode(Parent, _Household, Year)), % Parent has a PPA
    is_entitled_to_exemption_deduction(CaseID, Taxpayer, Parent, Year, _).

% hoh_limitations_apply(CaseID, Taxpayer, Year)
% §2(b)(3)
hoh_limitations_apply(CaseID, Taxpayer, Year) :-
    fact(CaseID, is_nonresident_alien(Taxpayer, Year)).
hoh_limitations_apply(CaseID, Taxpayer, Year) :-
    % (B) Dependent by reason of §152(d)(2)(H)
    is_dependent(CaseID, Taxpayer, Dependent, Year),
    \+ is_qualifying_child(CaseID, Taxpayer, Dependent, Year),
    fact(CaseID, member_of_household(Dependent, Taxpayer, Year)),
    % and no other relationship from (d)(2)(A-G) exists.
    \+ fact(CaseID, child_of(Dependent, Taxpayer)),
    \+ fact(CaseID, sibling_of(Dependent, Taxpayer)),
    \+ fact(CaseID, parent_of(Dependent, Taxpayer)),
    % ... and so on for all other relationship types. This is a simplification.
    true.
