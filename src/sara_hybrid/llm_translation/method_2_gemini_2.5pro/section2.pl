:- module(section2,
          [
            s2_a_is_surviving_spouse/3, % s2_a_is_surviving_spouse(CaseID, TaxpayerID, TaxYear)
            s2_b_is_head_of_household/3 % s2_b_is_head_of_household(CaseID, TaxpayerID, TaxYear)
          ]).

:- use_module(section151, [s151_is_entitled_to_deduction_for_dependent/4]).
:- use_module(section152, [s152_is_dependent/4, s152_is_qualifying_child/4, s152_c_is_qualifying_child_s152c/4]).
:- use_module(section7703, [s7703_is_married_gen_rule/3, s7703_is_legally_separated/3]).
:- use_module(helpers, [age_at_year_end/4]).

% (a) Definition of surviving spouse
s2_a_is_surviving_spouse(CaseID, TaxpayerID, TaxYear) :-
    s2_a_1_conditions_met(CaseID, TaxpayerID, TaxYear),
    \+ s2_a_2_limitations_apply(CaseID, TaxpayerID, TaxYear).

s2_a_1_conditions_met(CaseID, TaxpayerID, TaxYear) :-
    s2_a_1_A_spouse_died_recently(CaseID, TaxpayerID, TaxYear),
    s2_a_1_B_maintains_home_for_dependent_child(CaseID, TaxpayerID, TaxYear).

s2_a_1_A_spouse_died_recently(CaseID, TaxpayerID, TaxYear) :-
    fact(CaseID, spouse_of(TaxpayerID, SpouseID)),
    fact(CaseID, date_of_death(SpouseID, date(DeathYear, _, _))),
    PrecedingYear1 is TaxYear - 1,
    PrecedingYear2 is TaxYear - 2,
    (DeathYear =:= PrecedingYear1 ; DeathYear =:= PrecedingYear2).

s2_a_1_B_maintains_home_for_dependent_child(CaseID, TaxpayerID, TaxYear) :-
    fact(CaseID, child_of(DependentChildID, TaxpayerID)), % or stepchild
    ( fact(CaseID, relationship_is_son(DependentChildID, TaxpayerID));
      fact(CaseID, relationship_is_daughter(DependentChildID, TaxpayerID));
      fact(CaseID, relationship_is_stepson(DependentChildID, TaxpayerID));
      fact(CaseID, relationship_is_stepdaughter(DependentChildID, TaxpayerID))
    ),
    fact(CaseID, principal_place_of_abode(DependentChildID, TaxpayerID, TaxYear)), % Simplified: child lives with taxpayer
    fact(CaseID, member_of_household(DependentChildID, TaxpayerID, TaxYear)),
    s151_is_entitled_to_deduction_for_dependent(CaseID, TaxpayerID, DependentChildID, TaxYear), % Checks if dependent under S152
    s2_maintains_household_cost_condition(CaseID, TaxpayerID, TaxYear).

s2_maintains_household_cost_condition(CaseID, TaxpayerID, TaxYear) :-
    fact(CaseID, furnished_over_half_cost_of_maintaining_household(TaxpayerID, TaxYear)).

s2_a_2_limitations_apply(CaseID, TaxpayerID, TaxYear) :-
    s2_a_2_A_remarried(CaseID, TaxpayerID, TaxYear).
s2_a_2_limitations_apply(CaseID, TaxpayerID, TaxYear) :-
    s2_a_2_B_joint_return_not_possible_in_death_year(CaseID, TaxpayerID, TaxYear).

s2_a_2_A_remarried(CaseID, TaxpayerID, TaxYear) :-
    fact(CaseID, remarried_before_close_of_tax_year(TaxpayerID, TaxYear)).

s2_a_2_B_joint_return_not_possible_in_death_year(CaseID, TaxpayerID, _TaxYear) :- % CORRECTED: _TaxYear
    fact(CaseID, spouse_of(TaxpayerID, SpouseID)),
    fact(CaseID, date_of_death(SpouseID, date(DeathYear, _, _))),
    \+ s2_could_have_made_joint_return(CaseID, TaxpayerID, SpouseID, DeathYear).

s2_could_have_made_joint_return(CaseID, TaxpayerID, SpouseID, TaxYearForJointReturn) :-
    % A joint return can be made unless one was NRA
    \+ fact(CaseID, is_nonresident_alien(TaxpayerID, TaxYearForJointReturn)),
    \+ fact(CaseID, is_nonresident_alien(SpouseID, TaxYearForJointReturn)).


% (b) Definition of head of household
s2_b_is_head_of_household(CaseID, TaxpayerID, TaxYear) :-
    s2_b_1_general_conditions(CaseID, TaxpayerID, TaxYear),
    \+ s2_b_3_limitations_apply(CaseID, TaxpayerID, TaxYear).

s2_b_1_general_conditions(CaseID, TaxpayerID, TaxYear) :-
    s2_b_is_not_married_at_close_of_year(CaseID, TaxpayerID, TaxYear),
    \+ s2_a_is_surviving_spouse(CaseID, TaxpayerID, TaxYear),
    ( s2_b_1_A_maintains_home_for_qualifying_person(CaseID, TaxpayerID, TaxYear)
    ; s2_b_1_B_maintains_home_for_parent(CaseID, TaxpayerID, TaxYear)
    ).

s2_b_is_not_married_at_close_of_year(CaseID, TaxpayerID, TaxYear) :-
    % Default: check marital status under 7703
    ( \+ s7703_is_married_gen_rule(CaseID, TaxpayerID, TaxYear) -> true
    ;   % s2(b)(2) provides special overrides for HoH marital status
        s2_b_2_A_legally_separated(CaseID, TaxpayerID, TaxYear)
    ;   s2_b_2_B_spouse_is_nra(CaseID, TaxpayerID, TaxYear)
    ),
    % s2(b)(2)(C) says if spouse died, considered married. This is handled by s7703_is_married_gen_rule.
    % So for HoH, one should NOT be considered married if spouse died during year unless 7703b applies.
    % The logic "is_not_married" must align with s7703 and s2(b)(2) nuances.
    % s2(b)(1) uses "is not married at the close of his taxable year".
    % s7703(a)(1) "determination ... made as of the close of his taxable year;
    % except that if his spouse dies during his taxable year such determination shall be made as of the time of such death"
    % So if spouse died, s7703(a)(1) makes them married at time of death.
    % s2(b)(2)(C) effectively says for HoH purposes, if spouse died in year, you are "married" *unless* another rule (like 7703(b)) makes you unmarried.
    % This is complex. Let's simplify: if not married by 7703 OR s2(b)(2)(A) or s2(b)(2)(B) makes them not married.
    ( \+ fact(CaseID, is_married_determined_by_s7703_end_of_year(TaxpayerID, TaxYear)) ;
        fact(CaseID, is_considered_not_married_by_s2b2(TaxpayerID, TaxYear))
    ).

% Simplified placeholder for actual marital status check for HoH (integrating s7703 and s2(b)(2))
fact(CaseID, is_married_determined_by_s7703_end_of_year(TaxpayerID, TaxYear)) :-
    s7703_is_married_gen_rule(CaseID, TaxpayerID, TaxYear).

fact(CaseID, is_considered_not_married_by_s2b2(TaxpayerID, TaxYear)) :-
    s2_b_2_A_legally_separated(CaseID, TaxpayerID, TaxYear).
fact(CaseID, is_considered_not_married_by_s2b2(TaxpayerID, TaxYear)) :-
    s2_b_2_B_spouse_is_nra(CaseID, TaxpayerID, TaxYear).


s2_b_1_A_maintains_home_for_qualifying_person(CaseID, TaxpayerID, TaxYear) :-
    s2_maintains_household_cost_condition(CaseID, TaxpayerID, TaxYear), % Applies to (A) and (B)
    fact(CaseID, principal_place_of_abode_for_over_half_year(QualifyingPersonID, TaxpayerID, TaxYear)),
    fact(CaseID, member_of_household(QualifyingPersonID, TaxpayerID, TaxYear)),
    ( s2_b_1_A_i_qualifying_child(CaseID, TaxpayerID, QualifyingPersonID, TaxYear)
    ; s2_b_1_A_ii_other_dependent(CaseID, TaxpayerID, QualifyingPersonID, TaxYear)
    ).

s2_b_1_A_i_qualifying_child_limitation(CaseID, _TaxpayerID, ChildID, TaxYear) :- % CORRECTED: _TaxpayerID
    fact(CaseID, is_married_at_close_of_tax_year(ChildID, TaxYear)),
    fact(CaseID, spouse_of(ChildID, ChildSpouseID)),
    fact(CaseID, filed_joint_return(ChildID, ChildSpouseID, TaxYear)).
    
% Helper for the "not a dependent by reason of 152(b)(2)"
% s152_is_dependent_despite_marriage_exception means they are a dependent.
% The rule is: NOT if (child_is_married AND child_is_not_dependent_by_152b2)
% s152(b)(2) says: child is NOT dependent IF child_filed_joint_return.
% So, child is NOT QC for HoH if: child_is_married AND child_filed_joint_return.
% The text: "not if such child ... is married ... AND is not a dependent ... by reason of section 152(b)(2)"
% This means the child *is not a dependent* because the child filed a joint return.
% This path is excluded if child_is_married_at_close_of_taxpayers_year AND \+ s152_is_dependent_because_child_did_not_file_joint_return_s152b2.
% This is complex. The text phrasing "not if such child ... is not a dependent ... by reason of 152(b)(2)" means:
% IF child_is_married AND child_would_be_disqualified_as_dependent_by_s152b2 THEN child is not QC for HoH.
% s152_b_2_disqualifies_dependent(CaseID, ChildID, TaxYear) :- fact(CaseID, filed_joint_return(ChildID, _, TaxYear)).
s2_b_1_A_i_qualifying_child_limitation(CaseID, TaxpayerID, ChildID, TaxYear) :-
    fact(CaseID, is_married_at_close_of_tax_year(ChildID, TaxYear)), % Taxpayer's tax year for child's marriage status
    fact(CaseID, spouse_of(ChildID, ChildSpouseID)),
    fact(CaseID, filed_joint_return(ChildID, ChildSpouseID, TaxYear)). % Assuming child's tax year aligns for this check


s2_b_1_A_ii_other_dependent(CaseID, TaxpayerID, DependentID, TaxYear) :-
    s151_is_entitled_to_deduction_for_dependent(CaseID, TaxpayerID, DependentID, TaxYear).

s2_b_1_B_maintains_home_for_parent(CaseID, TaxpayerID, TaxYear) :-
    s2_maintains_household_cost_condition(CaseID, TaxpayerID, TaxYear),
    (fact(CaseID, father_of(ParentID, TaxpayerID)) ; fact(CaseID, mother_of(ParentID, TaxpayerID))),
    fact(CaseID, principal_place_of_abode_for_taxable_year(ParentID, _SomeHouseholdMaintainedByTaxpayer, TaxYear)), % The household for parent doesn't have to be taxpayer's home
    s151_is_entitled_to_deduction_for_dependent(CaseID, TaxpayerID, ParentID, TaxYear).

% (b)(2) Determination of status (Overrides for marital status for HoH purpose)
s2_b_2_A_legally_separated(CaseID, TaxpayerID, TaxYear) :-
    s7703_is_legally_separated(CaseID, TaxpayerID, TaxYear). % From s7703 module

s2_b_2_B_spouse_is_nra(CaseID, TaxpayerID, TaxYear) :-
    fact(CaseID, spouse_of(TaxpayerID, SpouseID)),
    fact(CaseID, is_nonresident_alien_any_time_during_year(SpouseID, TaxYear)).

% s2_b_2_C: if spouse died during year, taxpayer considered married.
% This is the default under s7703(a)(1) too. So this mainly confirms s7703 rule applies
% unless 7703(b) (certain married individuals living apart) makes them unmarried.
% This is implicitly handled by `s2_b_is_not_married_at_close_of_year` using s7703.

% (b)(3) Limitations
s2_b_3_limitations_apply(CaseID, TaxpayerID, TaxYear) :-
    s2_b_3_A_taxpayer_nra(CaseID, TaxpayerID, TaxYear).
s2_b_3_limitations_apply(CaseID, TaxpayerID, TaxYear) :-
    s2_b_3_B_dependent_by_152_d_2_H(CaseID, TaxpayerID, TaxYear). % Dependent only due to household membership

s2_b_3_A_taxpayer_nra(CaseID, TaxpayerID, TaxYear) :-
    fact(CaseID, is_nonresident_alien_any_time_during_year(TaxpayerID, TaxYear)).

s2_b_3_B_dependent_by_152_d_2_H(CaseID, TaxpayerID, TaxYear) :-
    % This means the person is a qualifying person for HoH status,
    % AND that person is only a dependent due to s152(d)(2)(H) (member of household, not related)
    s2_b_1_A_maintains_home_for_qualifying_person(CaseID, TaxpayerID, QualifyingPersonID, TaxYear),
    s152_is_dependent_solely_by_d_2_H(CaseID, TaxpayerID, QualifyingPersonID, TaxYear).

% Placeholder, s152 needs to export this if necessary
s152_is_dependent_solely_by_d_2_H(CaseID, TaxpayerID, DependentID, TaxYear) :-
    fact(CaseID, is_dependent_only_because_member_of_household_s152d2H(DependentID, TaxpayerID, TaxYear)).