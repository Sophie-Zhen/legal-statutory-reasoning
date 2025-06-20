:- module(section2,
          [ s2_a_is_surviving_spouse/4,         % s2_a_is_surviving_spouse(CaseID, TaxpayerID, TaxYear, IsSurvivingSpouseBool)
            s2_b_is_head_of_household/4         % s2_b_is_head_of_household(CaseID, TaxpayerID, TaxYear, IsHeadOfHouseholdBool)
          ]).

:- use_module(helpers, [get_age_at_year_end/4]).
:- use_module(section151, [s151_is_entitled_to_deduction_for_person/4]).
:- use_module(section152, [s152_is_dependent/4, s152_c_is_qualifying_child/4, s152_d_2_relationship_list/4]). % s152_d_2_relationship_list for 152(d)(2)(H) check
:- use_module(section7703, [s7703_is_married/4, s7703_is_legally_separated/4]).

:- dynamic fact/2.

% §2(a) Definition of surviving spouse
s2_a_is_surviving_spouse(CaseID, TaxpayerID, TaxYear, true) :-
    s2_a_1_A_spouse_died_recently(CaseID, TaxpayerID, TaxYear),
    s2_a_1_B_maintains_home_for_dependent_child(CaseID, TaxpayerID, TaxYear),
    \+ s2_a_2_A_taxpayer_remarried(CaseID, TaxpayerID, TaxYear),
    \+ s2_a_2_B_joint_return_not_possible_in_death_year(CaseID, TaxpayerID, TaxYear).
s2_a_is_surviving_spouse(_, _, _, false).

s2_a_1_A_spouse_died_recently(CaseID, TaxpayerID, TaxYear) :-
    fact(CaseID, spouse_of(TaxpayerID, SpouseID)),
    fact(CaseID, date_of_death(SpouseID, date(DeathYear, _, _))),
    (DeathYear =:= TaxYear - 1 ; DeathYear =:= TaxYear - 2).

s2_a_1_B_maintains_home_for_dependent_child(CaseID, TaxpayerID, TaxYear) :-
    fact(CaseID, maintains_household_as_home(TaxpayerID, _HouseholdID, TaxYear)),
    fact(CaseID, furnished_over_half_cost_of_maintaining_household(TaxpayerID, _HouseholdID, TaxYear)),
    fact(CaseID, principal_place_of_abode_in_household(DependentChildID, TaxpayerID, _HouseholdID, TaxYear)),
    fact(CaseID, member_of_household(DependentChildID, TaxpayerID, _HouseholdID, TaxYear)),
    ( fact(CaseID, relationship_son_of(DependentChildID, TaxpayerID))
    ; fact(CaseID, relationship_stepson_of(DependentChildID, TaxpayerID))
    ; fact(CaseID, relationship_daughter_of(DependentChildID, TaxpayerID))
    ; fact(CaseID, relationship_stepdaughter_of(DependentChildID, TaxpayerID))
    ),
    s152_is_dependent(CaseID, TaxpayerID, DependentChildID, TaxYear), % "within the meaning of section 152"
    s151_is_entitled_to_deduction_for_person(CaseID, TaxpayerID, DependentChildID, TaxYear). % "entitled to a deduction ... under section 151"

s2_a_2_A_taxpayer_remarried(CaseID, TaxpayerID, TaxYear) :-
    fact(CaseID, remarried_before_close_of_year(TaxpayerID, TaxYear)).

s2_a_2_B_joint_return_not_possible_in_death_year(CaseID, TaxpayerID, TaxYear) :-
    fact(CaseID, spouse_of(TaxpayerID, SpouseID)),
    fact(CaseID, date_of_death(SpouseID, date(DeathYear, _, _))), % Year spouse died
    \+ s2_joint_return_could_have_been_made(CaseID, TaxpayerID, SpouseID, DeathYear).

s2_joint_return_could_have_been_made(CaseID, TaxpayerID, SpouseID, TaxYearForReturn) :-
    \+ fact(CaseID, is_nonresident_alien_any_time_during_year(TaxpayerID, TaxYearForReturn)),
    \+ fact(CaseID, is_nonresident_alien_any_time_during_year(SpouseID, TaxYearForReturn)).

% §2(b) Definition of head of household
s2_b_is_head_of_household(CaseID, TaxpayerID, TaxYear, true) :-
    s2_b_1_is_not_married_at_close_of_year(CaseID, TaxpayerID, TaxYear),
    s2_a_is_surviving_spouse(CaseID, TaxpayerID, TaxYear, false), % Not a surviving spouse
    ( s2_b_1_A_maintains_home_qualifying_person(CaseID, TaxpayerID, TaxYear)
    ; s2_b_1_B_maintains_home_parent(CaseID, TaxpayerID, TaxYear)
    ),
    \+ s2_b_3_A_taxpayer_nra(CaseID, TaxpayerID, TaxYear),
    \+ s2_b_3_B_dependent_by_152d2H_only(CaseID, TaxpayerID, TaxYear).
s2_b_is_head_of_household(_, _, _, false).

s2_b_1_is_not_married_at_close_of_year(CaseID, TaxpayerID, TaxYear) :-
    ( s2_b_2_A_legally_separated(CaseID, TaxpayerID, TaxYear) -> true % Considered not married
    ; s2_b_2_B_spouse_nra(CaseID, TaxpayerID, TaxYear) -> true % Considered not married
    ; ( \+ s2_b_2_C_spouse_died_considered_married(CaseID, TaxpayerID, TaxYear), % If spouse died, usually considered married unless this is false
        s7703_is_married(CaseID, TaxpayerID, TaxYear, false) % General rule from 7703
      )
    ).

s2_b_1_A_maintains_home_qualifying_person(CaseID, TaxpayerID, TaxYear) :-
    fact(CaseID, maintains_household_as_home(TaxpayerID, _HouseholdID, TaxYear)),
    fact(CaseID, furnished_over_half_cost_of_maintaining_household(TaxpayerID, _HouseholdID, TaxYear)),
    fact(CaseID, principal_place_of_abode_in_household_more_than_half_year(QualifyingPersonID, TaxpayerID, _HouseholdID, TaxYear)),
    fact(CaseID, member_of_household(QualifyingPersonID, TaxpayerID, _HouseholdID, TaxYear)),
    ( s2_b_1_A_i_qualifying_child_hoh(CaseID, TaxpayerID, QualifyingPersonID, TaxYear)
    ; s2_b_1_A_ii_other_dependent_hoh(CaseID, TaxpayerID, QualifyingPersonID, TaxYear)
    ).

s2_b_1_A_i_qualifying_child_hoh(CaseID, TaxpayerID, ChildID, TaxYear) :-
    s152_c_is_qualifying_child(CaseID, TaxpayerID, ChildID, TaxYear), % As defined in 152(c)
    \+ ( fact(CaseID, is_married_at_close_of_taxpayers_year(ChildID, TaxYear)), % Child is married
         s152_b_2_exception_married_dependent_joint_return(CaseID, ChildID, TaxYear, true) % AND child is not dependent by reason of 152(b)(2) (filed joint)
       ).

s2_b_1_A_ii_other_dependent_hoh(CaseID, TaxpayerID, DependentID, TaxYear) :-
    s152_is_dependent(CaseID, TaxpayerID, DependentID, TaxYear), % Any other dependent
    s151_is_entitled_to_deduction_for_person(CaseID, TaxpayerID, DependentID, TaxYear).

s2_b_1_B_maintains_home_parent(CaseID, TaxpayerID, TaxYear) :-
    fact(CaseID, maintains_household_for_parent_principal_abode(TaxpayerID, ParentID, _HouseholdID, TaxYear)),
    fact(CaseID, furnished_over_half_cost_of_maintaining_household(TaxpayerID, _HouseholdID, TaxYear)),
    (fact(CaseID, relationship_father_of(ParentID, TaxpayerID)) ; fact(CaseID, relationship_mother_of(ParentID, TaxpayerID))),
    s151_is_entitled_to_deduction_for_person(CaseID, TaxpayerID, ParentID, TaxYear).

% §2(b)(2) Determination of status (for HoH)
s2_b_2_A_legally_separated(CaseID, TaxpayerID, TaxYear) :-
    s7703_is_legally_separated(CaseID, TaxpayerID, TaxYear, true).

s2_b_2_B_spouse_nra(CaseID, TaxpayerID, TaxYear) :-
    fact(CaseID, spouse_of(TaxpayerID, SpouseID)),
    fact(CaseID, is_nonresident_alien_any_time_during_year(SpouseID, TaxYear)).

s2_b_2_C_spouse_died_considered_married(CaseID, TaxpayerID, TaxYear) :- % Taxpayer considered married if spouse died during year (unless NRA spouse)
    fact(CaseID, spouse_of(TaxpayerID, SpouseID)),
    fact(CaseID, date_of_death(SpouseID, date(DeathYear, _, _))), DeathYear =:= TaxYear,
    \+ s2_b_2_B_spouse_nra(CaseID, TaxpayerID, TaxYear). % Not an NRA spouse

% §2(b)(3) Limitations (for HoH)
s2_b_3_A_taxpayer_nra(CaseID, TaxpayerID, TaxYear) :-
    fact(CaseID, is_nonresident_alien_any_time_during_year(TaxpayerID, TaxYear)).

s2_b_3_B_dependent_by_152d2H_only(CaseID, TaxpayerID, TaxYear) :-
    fact(CaseID, hoh_qualifying_person_is_152d2H(TaxpayerID, _QualifyingPersonID, TaxYear)).
    % This fact implies that the person qualifies Taxpayer for HoH, AND that person is only a dependent
    % due to being a member of household under 152(d)(2)(H), not by other relationships.