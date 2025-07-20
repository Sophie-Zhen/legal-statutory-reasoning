:- module(statute_2,
          [ filing_status/3,
            surviving_spouse_limitation_b/3
          ]).

/**
 * statute_2.pl
 *
 * This module implements §2, defining the filing statuses of "surviving spouse"
 * and "head of household". It provides the main predicate `filing_status/3`
 * which is a crucial entry point for determining tax rates.
 *
 * This module orchestrates checks from §7703 (marital status), §151 (deductions),
 * and §152 (dependents) to make its determinations.
 */

% The system will use module-qualified calls for dependencies, so no use_module needed.

% The system will provide the 'fact' predicates at runtime.
:- discontiguous fact/1, fact/2, fact/3, fact/4.

% filing_status(+Taxpayer, +Year, -Status)
%
% Determines the filing status for a taxpayer in a given year. The logic
% proceeds in a specific order as required by the tax code: surviving spouse,
% then head of household, then married statuses, with unmarried as the default.
% Status can be one of: surviving_spouse, head_of_household,
% married_filing_jointly, married_filing_separately, unmarried.
filing_status(Taxpayer, Year, surviving_spouse) :-
    is_surviving_spouse(Taxpayer, Year), !.

filing_status(Taxpayer, Year, head_of_household) :-
    is_head_of_household(Taxpayer, Year), !.

filing_status(Taxpayer, Year, married_filing_jointly) :-
    statute_7703:marital_status(Taxpayer, Year, married),
    fact(files_joint_return(Taxpayer, Year)), !.

filing_status(Taxpayer, Year, married_filing_separately) :-
    statute_7703:marital_status(Taxpayer, Year, married),
    fact(files_separate_return(Taxpayer, Year)), !.

filing_status(Taxpayer, Year, unmarried) :-
    statute_7703:marital_status(Taxpayer, Year, not_married).

% is_surviving_spouse(+Taxpayer, +Year)
%
% Implements §2(a). Succeeds if the taxpayer meets the criteria for a surviving spouse.
is_surviving_spouse(Taxpayer, Year) :-
    is_surviving_spouse_general_rule(Taxpayer, Year),
    is_not_limited_from_surviving_spouse(Taxpayer, Year).

is_surviving_spouse_general_rule(Taxpayer, Year) :-
    fact(spouse_died_in_preceding_years(Taxpayer, 2, Year)), % §2(a)(1)(A)
    % Find a qualifying dependent child for whom the household is maintained
    is_qualifying_dependent_for_surviving_spouse(Taxpayer, Dependent, Year), % §2(a)(1)(B)
    fact(furnishes_over_half_of_household_maintenance(Taxpayer, Year)),
    fact(has_same_principal_abode(Dependent, Taxpayer, Year, full_year)).

is_qualifying_dependent_for_surviving_spouse(Taxpayer, Dependent, Year) :-
    (fact(child_of(Dependent, Taxpayer)); fact(stepchild_of(Dependent, Taxpayer))),
    statute_151:deduction_for_dependent(Taxpayer, Dependent, Year).

is_not_limited_from_surviving_spouse(Taxpayer, Year) :-
    \+ fact(remarried_before_close_of_year(Taxpayer, Year)), % §2(a)(2)(A)
    fact(spouse_died_in_year(Taxpayer, Spouse, YearOfDeath, _)),
    surviving_spouse_limitation_b(Taxpayer, Spouse, YearOfDeath). % §2(a)(2)(B)

% surviving_spouse_limitation_b(+Taxpayer, +DeceasedSpouse, +YearOfDeath)
%
% Implements §2(a)(2)(B). Succeeds if a joint return could have been made
% in the year the spouse died. Exported for test s2_a_2_B_pos.
surviving_spouse_limitation_b(Taxpayer, DeceasedSpouse, YearOfDeath) :-
    \+ fact(nonresident_alien_at_any_time(Taxpayer, YearOfDeath)),
    \+ fact(nonresident_alien_at_any_time(DeceasedSpouse, YearOfDeath)).

% is_head_of_household(+Taxpayer, +Year)
%
% Implements §2(b). Succeeds if the taxpayer qualifies as a head of household.
is_head_of_household(Taxpayer, Year) :-
    % §2(b)(1) initial conditions & §2(b)(2) status determination
    is_considered_not_married_for_hoh(Taxpayer, Year),
    \+ is_surviving_spouse(Taxpayer, Year),
    % §2(b)(3) limitations
    \+ fact(nonresident_alien_at_any_time(Taxpayer, Year)),
    % §2(b)(1) household maintenance test
    fact(furnishes_over_half_of_household_maintenance(Taxpayer, Year)),
    ( maintains_household_for_qualifying_person_b1a(Taxpayer, Year)
    ; maintains_household_for_parent_b1b(Taxpayer, Year)
    ).

is_considered_not_married_for_hoh(Taxpayer, Year) :-
    statute_7703:marital_status(Taxpayer, Year, not_married), !.
is_considered_not_married_for_hoh(Taxpayer, Year) :-
    fact(spouse_of(Taxpayer, Spouse, Year)),
    fact(nonresident_alien_at_any_time(Spouse, Year)). % §2(b)(2)(B)

maintains_household_for_qualifying_person_b1a(Taxpayer, Year) :-
    find_hoh_qualifying_person(Taxpayer, Person, Year),
    fact(has_same_principal_abode(Person, Taxpayer, Year, more_than_half)).

maintains_household_for_parent_b1b(Taxpayer, Year) :-
    fact(parent_of(Parent, Taxpayer)),
    statute_151:deduction_for_dependent(Taxpayer, Parent, Year),
    fact(maintains_household_for_parent(Taxpayer, Parent, Year)).

% find_hoh_qualifying_person(+Taxpayer, -Person, +Year)
%
% Finds a person who qualifies the taxpayer for HoH status under §2(b)(1)(A).
% This logic includes the limitations from §2(b)(1)(A)(i) and §2(b)(3)(B).
find_hoh_qualifying_person(Taxpayer, Person, Year) :-
    % Case (i): a qualifying child, with a check for marriage status
    ( statute_152:is_qualifying_child(Taxpayer, Person, Year),
      % If the child is married, they must still be a dependent.
      (\+ fact(is_married_at_close_of_year(Person, Year));
         statute_152:is_dependent(Taxpayer, Person, Year, _))
    )
    ;
    % Case (ii): any other dependent
    ( statute_152:is_dependent(Taxpayer, Person, Year, _),
      \+ statute_152:is_qualifying_child(Taxpayer, Person, Year),
      statute_151:deduction_for_dependent(Taxpayer, Person, Year),
      % §2(b)(3)(B) limitation: person cannot be dependent solely due to being a household member
      \+ is_dependent_only_by_household_rule(Taxpayer, Person, Year)
    ).

is_dependent_only_by_household_rule(Taxpayer, Person, Year) :-
    statute_152:is_dependent(Taxpayer, Person, Year, qualifying_relative),
    statute_152:relationship_d2(Person, Taxpayer, 'H').