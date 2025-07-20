:- module(section2,
          [ filing_status/4,             % filing_status(Taxpayer, CaseID, Year, Status)
            is_surviving_spouse/3,       % is_surviving_spouse(Taxpayer, CaseID, Year)
            is_head_of_household/3,      % is_head_of_household(Taxpayer, CaseID, Year)
            could_have_filed_joint_return_in_death_year/2 % could_have_filed_joint_return_in_death_year(Taxpayer, Year)
          ]).

:- use_module(tests, [fact/2]).
:- use_module(section7703, [is_married_a/3, is_considered_not_married_b/3]).
:- use_module(section151, [is_entitled_to_deduction_for_dependent/4]).
:- use_module(section152, [is_qualifying_child/4, is_dependent/4]).


% Top-level predicate to determine a taxpayer's filing status.
filing_status(Taxpayer, CaseID, Year, surviving_spouse) :-
    is_surviving_spouse(Taxpayer, CaseID, Year), !.
filing_status(Taxpayer, CaseID, Year, head_of_household) :-
    is_head_of_household(Taxpayer, CaseID, Year), !.
filing_status(Taxpayer, CaseID, Year, married_filing_jointly) :-
    is_married_a(Taxpayer, CaseID, Year),
    \+ is_considered_not_married_b(Taxpayer, CaseID, Year),
    fact(CaseID, spouse(Taxpayer, Spouse)),
    fact(CaseID, files_joint_return(Taxpayer, Spouse, Year)), !.
filing_status(Taxpayer, CaseID, Year, married_filing_separately) :-
    is_married_a(Taxpayer, CaseID, Year),
    \+ is_considered_not_married_b(Taxpayer, CaseID, Year),
    (fact(CaseID, files_separate_return(Taxpayer, Year)) ; (fact(CaseID, spouse(Taxpayer, Spouse)), \+ fact(CaseID, files_joint_return(Taxpayer, Spouse, Year)))), !.
filing_status(Taxpayer, _CaseID, _Year, single) :-
    % A taxpayer is 'single' if they are not any of the other statuses.
    true.


% §2(a) Definition of surviving spouse
is_surviving_spouse(Taxpayer, CaseID, Year) :-
    % (1)(A) Spouse died in one of the two preceding years.
    fact(CaseID, spouse(Taxpayer, Spouse)),
    fact(CaseID, death_of_spouse(Taxpayer, Spouse, date(DeathYear, _, _))),
    (Year - DeathYear =:= 1 ; Year - DeathYear =:= 2),
    % (1)(B) Maintains a home for a dependent son/daughter.
    maintains_home_for_dependent_child(Taxpayer, CaseID, Year),
    % (2)(A) Taxpayer has not remarried.
    \+ fact(CaseID, remarried(Taxpayer, Year)),
    % (2)(B) Could have filed a joint return in the year of death.
    could_have_filed_joint_return_in_death_year(Taxpayer, DeathYear).

could_have_filed_joint_return_in_death_year(Taxpayer, DeathYear) :-
    fact(CaseID, spouse(Taxpayer, Spouse)),
    % Not a nonresident alien.
    \+ fact(CaseID, nonresident_alien(Taxpayer, DeathYear)),
    \+ fact(CaseID, nonresident_alien(Spouse, DeathYear)).

maintains_home_for_dependent_child(Taxpayer, CaseID, Year) :-
    fact(CaseID, maintains_household_as_principal_abode(Taxpayer, Child, Year)),
    is_entitled_to_deduction_for_dependent(Taxpayer, Child, CaseID, Year),
    is_son_or_daughter(Child, Taxpayer, CaseID).

is_son_or_daughter(Child, Parent, CaseID) :-
    (   fact(CaseID, child_of(Child, Parent))
    ;   fact(CaseID, stepchild_of(Child, Parent))
    ).

% §2(b) Definition of head of household
is_head_of_household(Taxpayer, CaseID, Year) :-
    % §2(b)(1) Conditions
    \+ is_married_at_close_of_year(Taxpayer, CaseID, Year),
    \+ is_surviving_spouse(Taxpayer, CaseID, Year),
    maintains_household_for_qualifying_person(Taxpayer, CaseID, Year),
    % §2(b)(3) Limitations
    \+ fact(CaseID, nonresident_alien(Taxpayer, Year)),
    \+ is_hoh_disqualified_by_household_member(Taxpayer, CaseID, Year).

% Helper for §2(b)(1): is not married at close of year
is_married_at_close_of_year(Taxpayer, CaseID, Year) :-
    is_married_a(Taxpayer, CaseID, Year),
    % Not unmarried due to special rules in §2(b)(2)
    \+ is_considered_not_married_for_hoh(Taxpayer, CaseID, Year),
    % Not unmarried due to §7703(b) 'living apart' rule
    \+ is_considered_not_married_b(Taxpayer, CaseID, Year).

is_considered_not_married_for_hoh(Taxpayer, CaseID, Year) :-
    fact(CaseID, spouse(Taxpayer, Spouse)),
    % §2(b)(2)(A) legally separated
    fact(CaseID, legally_separated(Taxpayer, Spouse, date(SepYear,_,_))), SepYear =< Year.
is_considered_not_married_for_hoh(Taxpayer, CaseID, Year) :-
    % §2(b)(2)(B) spouse is nonresident alien
    fact(CaseID, spouse(Taxpayer, Spouse)),
    fact(CaseID, nonresident_alien(Spouse, Year)).


% Helper for §2(b)(1): Maintains household for a qualifying person
maintains_household_for_qualifying_person(Taxpayer, CaseID, Year) :-
    fact(CaseID, furnishes_over_half_cost_of_household(Taxpayer, Year)),
    (   % (A) Qualifying Child
        maintains_household_for_qualifying_child(Taxpayer, CaseID, Year)
    ;   % (A)(ii) Other dependent
        maintains_household_for_other_dependent(Taxpayer, CaseID, Year)
    ;   % (B) Father or Mother
        maintains_household_for_parent(Taxpayer, CaseID, Year)
    ).

maintains_household_for_qualifying_child(Taxpayer, CaseID, Year) :-
    is_qualifying_child(Taxpayer, Child, CaseID, Year),
    fact(CaseID, lived_with_over_half_year(Child, Taxpayer, Year)),
    \+ (
        fact(CaseID, spouse(Child, _)),
        is_dependent_ineligible_married(Child, CaseID, Year)
    ).

is_dependent_ineligible_married(Child, CaseID, Year) :-
    % From §152(b)(2) via §2(b)(1)(A)(i)(II)
    fact(CaseID, spouse(Child, Spouse)),
    fact(CaseID, files_joint_return(Child, Spouse, Year)).

maintains_household_for_other_dependent(Taxpayer, CaseID, Year) :-
    is_dependent(Taxpayer, Dependent, CaseID, Year),
    is_entitled_to_deduction_for_dependent(Taxpayer, Dependent, CaseID, Year),
    fact(CaseID, lived_with_over_half_year(Dependent, Taxpayer, Year)).

maintains_household_for_parent(Taxpayer, CaseID, Year) :-
    is_dependent(Taxpayer, Parent, CaseID, Year),
    (fact(CaseID, child_of(Taxpayer, Parent)); fact(CaseID, mother_of(Parent, Taxpayer)); fact(CaseID, father_of(Parent, Taxpayer))),
    is_entitled_to_deduction_for_dependent(Taxpayer, Parent, CaseID, Year),
    fact(CaseID, maintains_household_as_principal_abode(Taxpayer, Parent, Year)).

% Helper for §2(b)(3)(B) limitation
is_hoh_disqualified_by_household_member(Taxpayer, CaseID, Year) :-
    is_dependent(Taxpayer, Dependent, CaseID, Year),
    % Checks if the *only* reason they are a dependent is §152(d)(2)(H)
    % We model this by checking if they meet the household member rule and fail others.
    fact(CaseID, member_of_household(Dependent, Taxpayer, Year)),
    \+ relationship_qualifying_relative_non_household(Taxpayer, Dependent, CaseID).

relationship_qualifying_relative_non_household(Taxpayer, Dependent, CaseID) :-
    section152:relationship_qualifying_relative(Taxpayer, Dependent, CaseID),
    \+ (
        fact(CaseID, same_principal_place_of_abode(Dependent, Taxpayer, _)),
        fact(CaseID, member_of_household(Dependent, Taxpayer, _))
    ).
