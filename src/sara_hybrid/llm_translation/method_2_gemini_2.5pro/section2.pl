:- module(section2,
          [
            s2_a_is_surviving_spouse/4, % s2_a_is_surviving_spouse(CaseID, TaxpayerID, TaxYear, IsSurvivingSpouseBool)
            s2_b_is_head_of_household/4 % s2_b_is_head_of_household(CaseID, TaxpayerID, TaxYear, IsHoHBool)
          ]).
:- use_module(section151, [s151_entitled_to_deduction_for_individual/5]). % s151_entitled_to_deduction_for_individual(CaseID, TaxpayerID, IndividualID, TaxYear, IsEntitledBool)
:- use_module(section152, [s152_is_dependent/5, s152_c_qualifying_child/5, s152_b_2_married_dependent_joint_return/4, s152_d_2_relationship_qr_met/4]).
:- use_module(section7703, [s7703_determination_of_marital_status/4]). % For marital status checks
:- use_module(helpers, [get_year_from_date/2]).
:- use_module(tests, [fact/2]). % Or pass facts
% s2_a_is_surviving_spouse(CaseID, TaxpayerID, TaxYear, IsSurvivingSpouseBool)
s2_a_is_surviving_spouse(CaseID, TaxpayerID, TaxYear, true) :-
    s2_a_1_conditions_ss(CaseID, TaxpayerID, TaxYear, true),
    \+ s2_a_2_limitations_apply_ss(CaseID, TaxpayerID, TaxYear, true),
    !.
s2_a_is_surviving_spouse(_, _, _, false).
% s2_a_1_conditions_ss(CaseID, TaxpayerID, TaxYear, ConditionsMetBool)
s2_a_1_conditions_ss(CaseID, TaxpayerID, TaxYear, true) :-
    s2_a_1_A_spouse_died_preceding_2_years(CaseID, TaxpayerID, TaxYear, true),
    s2_a_1_B_maintains_home_for_dependent_child_ss(CaseID, TaxpayerID, TaxYear, true),
    s2_a_1_maintains_household_cost_ss(CaseID, TaxpayerID, TaxYear, true),
    !.
s2_a_1_conditions_ss(_, _, _, false).
% s2_a_1_A_spouse_died_preceding_2_years(CaseID, TaxpayerID, TaxYear, MetBool)
s2_a_1_A_spouse_died_preceding_2_years(CaseID, TaxpayerID, TaxYear, true) :-
    fact(CaseID, spouse_of(TaxpayerID, SpouseID)),
    fact(CaseID, person_died_on(SpouseID, date(DeathYear, _M, _D))),
    (TaxYear - DeathYear =:= 1 ; TaxYear - DeathYear =:= 2),
    !.
s2_a_1_A_spouse_died_preceding_2_years(_, _, _, false).
% s2_a_1_B_maintains_home_for_dependent_child_ss(CaseID, TaxpayerID, TaxYear, MetBool)
s2_a_1_B_maintains_home_for_dependent_child_ss(CaseID, TaxpayerID, TaxYear, true) :-
    fact(CaseID, maintains_home_principal_abode_for_individual(TaxpayerID, DependentChildID, TaxYear)),
    % (i) who (within the meaning of section 152) is a son, stepson, daughter, or stepdaughter of the taxpayer
    s2_a_1_B_i_child_relationship_ss(CaseID, TaxpayerID, DependentChildID, true),
    s152_is_dependent(CaseID, TaxpayerID, DependentChildID, TaxYear, true), % Check if dependent under 152
    % (ii) with respect to whom the taxpayer is entitled to a deduction for the taxable year under section 151
    s151_entitled_to_deduction_for_individual(CaseID, TaxpayerID, DependentChildID, TaxYear, true),
    !.
s2_a_1_B_maintains_home_for_dependent_child_ss(_, _, _, false).
s2_a_1_B_i_child_relationship_ss(CaseID, TaxpayerID, ChildID, true) :-
    ( fact(CaseID, relationship_child_of(ChildID, TaxpayerID)) % ChildID is child of TaxpayerID
    ; fact(CaseID, relationship_stepchild_of(ChildID, TaxpayerID)) % ChildID is stepchild of TaxpayerID
    ), !.
s2_a_1_B_i_child_relationship_ss(_, _, _, false).
s2_a_1_maintains_household_cost_ss(CaseID, TaxpayerID, TaxYear, true) :-
    fact(CaseID, furnished_over_half_cost_of_maintaining_household(TaxpayerID, TaxYear)),
    !.
s2_a_1_maintains_household_cost_ss(_, _, _, false).
% s2_a_2_limitations_apply_ss(CaseID, TaxpayerID, TaxYear, LimitationAppliesBool)
s2_a_2_limitations_apply_ss(CaseID, TaxpayerID, TaxYear, true) :-
    s2_a_2_A_remarried_ss(CaseID, TaxpayerID, TaxYear, true),
    !.
s2_a_2_limitations_apply_ss(CaseID, TaxpayerID, TaxYear, true) :-
    s2_a_2_B_joint_return_could_not_be_made_ss(CaseID, TaxpayerID, TaxYear, true), % TaxYear here is the current year, but rule refers to year spouse died.
    !.
s2_a_2_limitations_apply_ss(_, _, _, false).
% s2_a_2_A_remarried_ss(CaseID, TaxpayerID, TaxYear, RemarriedBool)
s2_a_2_A_remarried_ss(CaseID, TaxpayerID, TaxYear, true) :-
    fact(CaseID, remarried_before_close_of_tax_year(TaxpayerID, TaxYear)),
    !.
s2_a_2_A_remarried_ss(_, _, _, false).
% s2_a_2_B_joint_return_could_not_be_made_ss(CaseID, TaxpayerID, TaxYear, CouldNotBeMadeBool)
% This applies to the taxpayer's taxable year during which HIS SPOUSE DIED.
s2_a_2_B_joint_return_could_not_be_made_ss(CaseID, TaxpayerID, _CurrentTaxYear, true) :-
    fact(CaseID, spouse_of(TaxpayerID, DeceasedSpouseID)), % Original spouse who died
    fact(CaseID, person_died_on(DeceasedSpouseID, date(YearSpouseDied, _, _))),
    \+ s2_a_2_B_joint_return_possible(CaseID, TaxpayerID, DeceasedSpouseID, YearSpouseDied, true),
    !.
s2_a_2_B_joint_return_could_not_be_made_ss(_, _, _, false).
% s2_a_2_B_joint_return_possible(CaseID, TaxpayerID, SpouseID, TaxYearOfDeath, PossibleBool)
s2_a_2_B_joint_return_possible(CaseID, TaxpayerID, SpouseID, TaxYearOfDeath, true) :-
    % "no joint return shall be made if either the husband or wife at any time during the taxable year is a nonresident alien."
    \+ fact(CaseID, is_nonresident_alien(TaxpayerID, TaxYearOfDeath)),
    \+ fact(CaseID, is_nonresident_alien(SpouseID, TaxYearOfDeath)),
    % Other conditions for joint return are generally met if they were married.
    !.
s2_a_2_B_joint_return_possible(_, _, _, _, false).
% s2_b_is_head_of_household(CaseID, TaxpayerID, TaxYear, IsHoHBool)
s2_b_is_head_of_household(CaseID, TaxpayerID, TaxYear, true) :-
    s2_b_1_conditions_hoh(CaseID, TaxpayerID, TaxYear, true),
    \+ s2_b_3_limitations_apply_hoh(CaseID, TaxpayerID, TaxYear, true),
    !.
s2_b_is_head_of_household(_, _, _, false).
% s2_b_1_conditions_hoh(CaseID, TaxpayerID, TaxYear, ConditionsMetBool)
s2_b_1_conditions_hoh(CaseID, TaxpayerID, TaxYear, true) :-
    s2_b_not_married_at_close_of_year_hoh(CaseID, TaxpayerID, TaxYear, true),
    \+ s2_a_is_surviving_spouse(CaseID, TaxpayerID, TaxYear, true), % is NOT a surviving spouse
    ( s2_b_1_A_maintains_home_qc_or_other_dependent_hoh(CaseID, TaxpayerID, TaxYear, true)
    ; s2_b_1_B_maintains_home_for_parent_hoh(CaseID, TaxpayerID, TaxYear, true)
    ),
    s2_b_1_maintains_household_cost_hoh(CaseID, TaxpayerID, TaxYear, true), % Common requirement
    !.
s2_b_1_conditions_hoh(_, _, _, false).
% Marital status for HoH, considering s2(b)(2) rules
s2_b_not_married_at_close_of_year_hoh(CaseID, TaxpayerID, TaxYear, true) :-
    s2_b_2_determination_of_status_hoh(CaseID, TaxpayerID, TaxYear, not_married),
    !.
s2_b_not_married_at_close_of_year_hoh(_, _, _, false).
% s2_b_1_A_maintains_home_qc_or_other_dependent_hoh(CaseID, TaxpayerID, TaxYear, MetBool)
s2_b_1_A_maintains_home_qc_or_other_dependent_hoh(CaseID, TaxpayerID, TaxYear, true) :-
    fact(CaseID, maintains_home_principal_abode_gt_half_year_for_individual(TaxpayerID, QualifyingPersonID, TaxYear)),
    ( s2_b_1_A_i_qualifying_child_hoh(CaseID, TaxpayerID, QualifyingPersonID, TaxYear, true)
    ; s2_b_1_A_ii_other_dependent_hoh(CaseID, TaxpayerID, QualifyingPersonID, TaxYear, true)
    ),
    !.
s2_b_1_A_maintains_home_qc_or_other_dependent_hoh(_, _, _, false).
% s2_b_1_A_i_qualifying_child_hoh(CaseID, TaxpayerID, ChildID, TaxYear, MetBool)
s2_b_1_A_i_qualifying_child_hoh(CaseID, TaxpayerID, ChildID, TaxYear, true) :-
    s152_c_qualifying_child(CaseID, TaxpayerID, ChildID, TaxYear, true),
    \+ ( % "but not if such child -"
        fact(CaseID, is_married_at_close_of_year(ChildID, TaxpayerID, TaxYear)) % Child married at close of *taxpayer's* year
        % (II) is not a dependent of such individual by reason of section 152(b)(2)
        % This means if the child filed a joint return (s152(b)(2)), they are not a dependent for this purpose.
        % s152_c_qualifying_child already checks s152(c)(1)(E) which is similar (child not filing joint return).
        % If s152_c_qualifying_child is true, then 152(c)(1)(E) is met.
        % 152(b)(2) is "An individual shall not be treated as a dependent ... if such individual has made a joint return"
        % This seems redundant if s152_c_qualifying_child is already true, as it implies child didn't file joint return (or filed for refund only).
        % Let's assume s152_c_qualifying_child handles the joint return aspect sufficiently via 152(c)(1)(E).
        % The critical part is "is not a dependent ... by reason of 152(b)(2)".
        % This means if the *only* reason they are NOT a dependent is 152(b)(2), then this condition kicks in.
        % This is complex. A simpler reading: the child must be a dependent.
        % s152_is_dependent checks 152(b)(2). So if s152_is_dependent(Child) is true, then 152(b)(2) didn't disqualify them.
        % The phrasing "not a dependent ... BY REASON OF 152(b)(2)" means 152(b)(2) IS the reason.
        % So, if s152_b_2_married_dependent_joint_return(CaseID, ChildID, TaxYear, true) is true, this condition (II) is met.
        % And if child is married (I) AND (II) is met, then this QC does not qualify the TP for HoH.
        , s152_b_2_married_dependent_joint_return(CaseID, ChildID, TaxYear, true) % Child filed joint return
    ),
    % For HoH, the qualifying child does not necessarily have to be a dependent if they are unmarried.
    % "a qualifying child ... but not if such child (I) is married ... AND (II) is not a dependent ... by reason of 152(b)(2)"
    % This means:
    % IF child is UNMARRIED QC -> qualifies taxpayer for HOH (no dependency needed for unmarried QC for HOH).
    % IF child is MARRIED QC -> then child must ALSO be a dependent (i.e. not fail 152(b)(2)).
    ( \+ fact(CaseID, is_married_at_close_of_year(ChildID, TaxpayerID, TaxYear)) -> true % Unmarried QC is fine
    ;   % Married QC: must be a dependent (meaning 152(b)(2) doesn't apply to make them non-dependent)
        s151_entitled_to_deduction_for_individual(CaseID, TaxpayerID, ChildID, TaxYear, true) % This implies they are a dependent.
    ),
    !.
s2_b_1_A_i_qualifying_child_hoh(_, _, _, _, false).
% s2_b_1_A_ii_other_dependent_hoh(CaseID, TaxpayerID, DependentID, TaxYear, MetBool)
s2_b_1_A_ii_other_dependent_hoh(CaseID, TaxpayerID, DependentID, TaxYear, true) :-
    s152_is_dependent(CaseID, TaxpayerID, DependentID, TaxYear, true), % Is a dependent (could be QR or QC not meeting above)
    s151_entitled_to_deduction_for_individual(CaseID, TaxpayerID, DependentID, TaxYear, true),
    !.
s2_b_1_A_ii_other_dependent_hoh(_, _, _, _, false).
% s2_b_1_B_maintains_home_for_parent_hoh(CaseID, TaxpayerID, TaxYear, MetBool)
s2_b_1_B_maintains_home_for_parent_hoh(CaseID, TaxpayerID, TaxYear, true) :-
    fact(CaseID, relationship_parent_of(ParentID, TaxpayerID)), % ParentID is parent of TaxpayerID
    fact(CaseID, maintains_household_principal_abode_for_parent(TaxpayerID, ParentID, TaxYear)), % Parent need not live with TP
    s151_entitled_to_deduction_for_individual(CaseID, TaxpayerID, ParentID, TaxYear, true),
    !.
s2_b_1_B_maintains_home_for_parent_hoh(_, _, _, false).
s2_b_1_maintains_household_cost_hoh(CaseID, TaxpayerID, TaxYear, true) :-
    fact(CaseID, furnished_over_half_cost_of_maintaining_household(TaxpayerID, TaxYear)), % For the household of the qualifying person
    !.
s2_b_1_maintains_household_cost_hoh(_, _, _, false).
% s2_b_2_determination_of_status_hoh(CaseID, TaxpayerID, TaxYear, MaritalStatusAtom)
% MaritalStatusAtom: married, not_married
s2_b_2_determination_of_status_hoh(CaseID, TaxpayerID, TaxYear, not_married) :-
    s2_b_2_A_legally_separated_hoh(CaseID, TaxpayerID, TaxYear, true),
    !.
s2_b_2_determination_of_status_hoh(CaseID, TaxpayerID, TaxYear, not_married) :-
    s2_b_2_B_spouse_nonresident_alien_hoh(CaseID, TaxpayerID, TaxYear, true),
    !.
s2_b_2_determination_of_status_hoh(CaseID, TaxpayerID, TaxYear, married) :- % Default from 7703 if (C) applies
    s2_b_2_C_spouse_died_during_year_hoh(CaseID, TaxpayerID, TaxYear, true),
    !.
s2_b_2_determination_of_status_hoh(CaseID, TaxpayerID, TaxYear, StatusFrom7703) :- % Fallback to general 7703 status
    s7703_determination_of_marital_status(CaseID, TaxpayerID, TaxYear, Status7703),
    ( (Status7703 == married ; Status7703 == considered_not_married_living_apart) -> % considered_not_married for 7703b is still married for 2(b) unless 2(b)(2) applies
        StatusFrom7703 = married % If 7703 says married, and 2(b)(2)(A,B) don't apply, then married for HoH initial check
    ; StatusFrom7703 = not_married % If 7703 says not_married
    ).
% s2_b_2_A_legally_separated_hoh(CaseID, TaxpayerID, TaxYear, IsNotMarriedBool)
s2_b_2_A_legally_separated_hoh(CaseID, TaxpayerID, TaxYear, true) :-
    fact(CaseID, legally_separated_under_decree(TaxpayerID, _SpouseID, TaxYear)),
    !.
s2_b_2_A_legally_separated_hoh(_, _, _, false).
% s2_b_2_B_spouse_nonresident_alien_hoh(CaseID, TaxpayerID, TaxYear, IsNotMarriedBool)
s2_b_2_B_spouse_nonresident_alien_hoh(CaseID, TaxpayerID, TaxYear, true) :-
    fact(CaseID, spouse_of(TaxpayerID, SpouseID)),
    fact(CaseID, is_nonresident_alien_any_time_during_year(SpouseID, TaxYear)),
    !.
s2_b_2_B_spouse_nonresident_alien_hoh(_, _, _, false).
% s2_b_2_C_spouse_died_during_year_hoh(CaseID, TaxpayerID, TaxYear, IsConsideredMarriedBool)
% If spouse died during year, taxpayer is considered married for that year (for HoH initial check, then check Surviving Spouse)
s2_b_2_C_spouse_died_during_year_hoh(CaseID, TaxpayerID, TaxYear, true) :-
    fact(CaseID, spouse_of(TaxpayerID, SpouseID)),
    \+ fact(CaseID, is_nonresident_alien_any_time_during_year(SpouseID, TaxYear)), % Spouse not described in (B)
    fact(CaseID, person_died_on(SpouseID, date(YearDied, _, _))),
    YearDied == TaxYear,
    !.
s2_b_2_C_spouse_died_during_year_hoh(_, _, _, false).
% s2_b_3_limitations_apply_hoh(CaseID, TaxpayerID, TaxYear, LimitationAppliesBool)
s2_b_3_limitations_apply_hoh(CaseID, TaxpayerID, TaxYear, true) :-
    s2_b_3_A_taxpayer_nonresident_alien_hoh(CaseID, TaxpayerID, TaxYear, true),
    !.
s2_b_3_limitations_apply_hoh(CaseID, TaxpayerID, TaxYear, true) :-
    s2_b_3_B_dependent_by_152_d_2_H_hoh(CaseID, TaxpayerID, TaxYear, true),
    !.
s2_b_3_limitations_apply_hoh(_, _, _, false).
% s2_b_3_A_taxpayer_nonresident_alien_hoh(CaseID, TaxpayerID, TaxYear, IsNonResidentAlienBool)
s2_b_3_A_taxpayer_nonresident_alien_hoh(CaseID, TaxpayerID, TaxYear, true) :-
    fact(CaseID, is_nonresident_alien_any_time_during_year(TaxpayerID, TaxYear)),
    !.
s2_b_3_A_taxpayer_nonresident_alien_hoh(_, _, _, false).
% s2_b_3_B_dependent_by_152_d_2_H_hoh(CaseID, TaxpayerID, TaxYear, LimitationAppliesBool)
% Limitation applies if HoH status is BY REASON OF an individual who would not be a dependent BUT FOR 152(d)(2)(H) (member of household rule)
s2_b_3_B_dependent_by_152_d_2_H_hoh(CaseID, TaxpayerID, TaxYear, true) :-
    % Find the qualifying person for HoH
    (   ( s2_b_1_A_maintains_home_qc_or_other_dependent_hoh(CaseID, TaxpayerID, TaxYear, QualifyingPersonID, true)
        ; s2_b_1_B_maintains_home_for_parent_hoh(CaseID, TaxpayerID, ParentID, TaxYear, true), QualifyingPersonID = ParentID % This case is unlikely to be 152d2H
        % Need to refine how QualifyingPersonID is passed/found
        % Assume QualifyingPersonID is the one from s2_b_1_A_ii_other_dependent_hoh or s2_b_1_A_i_qualifying_child_hoh
        % This predicate must be called knowing WHO the qualifying person is.
        % Let's assume it's passed in or this predicate needs refactoring to find that person.
        % For now, let's assume facts provide who the HOH qualifying person is:
          fact(CaseID, hoh_qualifying_person_for(TaxpayerID, TaxYear, QualifyingPersonID))
        )
    ),
    s152_is_dependent(CaseID, TaxpayerID, QualifyingPersonID, TaxYear, true), % The person IS a dependent
    % Now check if they are dependent ONLY because of 152(d)(2)(H)
    s152_d_2_relationship_qr_met(CaseID, TaxpayerID, QualifyingPersonID, TaxYear, MetByH), % Check if 152(d)(2)(H) specifically is met
    MetByH == s152_d_2_H, % Placeholder for specific check of which sub-clause of d2 made it true
    % To implement "but for":
    % 1. The person IS a dependent.
    % 2. The relationship IS s152(d)(2)(H).
    % 3. If we IGNORE s152(d)(2)(H), they would NOT be a dependent (or not meet relationship for QR).
    % This is complex. A simpler interpretation: if the qualifying person is a dependent *due to* 152(d)(2)(H), then HoH is disallowed.
    % So, we need to know if QualifyingPersonID's relationship to TaxpayerID is ONLY under 152(d)(2)(H).
    s152_d_2_relationship_is_only_H(CaseID, TaxpayerID, QualifyingPersonID, TaxYear, true),
    !.
s2_b_3_B_dependent_by_152_d_2_H_hoh(_, _, _, false).
% Helper: s2_b_1_A_maintains_home_qc_or_other_dependent_hoh needs to bind QualifyingPersonID
s2_b_1_A_maintains_home_qc_or_other_dependent_hoh(CaseID, TaxpayerID, TaxYear, QualifyingPersonID, true) :-
    fact(CaseID, maintains_home_principal_abode_gt_half_year_for_individual(TaxpayerID, QualifyingPersonID, TaxYear)),
    ( s2_b_1_A_i_qualifying_child_hoh(CaseID, TaxpayerID, QualifyingPersonID, TaxYear, true)
    ; s2_b_1_A_ii_other_dependent_hoh(CaseID, TaxpayerID, QualifyingPersonID, TaxYear, true)
    ),
    !.
s2_b_1_A_maintains_home_qc_or_other_dependent_hoh(_, _, _, _, false).
% s152_d_2_relationship_is_only_H(CaseID, TaxpayerID, IndividualID, TaxYear, IsOnlyHBool)
% True if the *only* qualifying relationship under s152(d)(2) is (H).
s152_d_2_relationship_is_only_H(CaseID, TaxpayerID, IndividualID, TaxYear, true) :-
    s152_d_2_H_member_of_household(CaseID, TaxpayerID, IndividualID, TaxYear, true), % (H) is met
    % And no other relationship from s152(d)(2)(A)-(G) is met
    \+ (
        ( fact(CaseID, relationship_child_of(IndividualID, TaxpayerID))
        ; fact(CaseID, relationship_descendant_of_child(IndividualID, TaxpayerID))
        ; fact(CaseID, relationship_sibling_of(IndividualID, TaxpayerID))
        ; fact(CaseID, relationship_step_sibling_of(IndividualID, TaxpayerID))
        ; fact(CaseID, relationship_parent_of(IndividualID, TaxpayerID))
        ; fact(CaseID, relationship_ancestor_of_parent(IndividualID, TaxpayerID))
        ; fact(CaseID, relationship_step_parent_of(IndividualID, TaxpayerID))
        ; fact(CaseID, relationship_child_of_sibling(IndividualID, TaxpayerID))
        ; fact(CaseID, relationship_sibling_of_parent(IndividualID, TaxpayerID))
        ; fact(CaseID, relationship_in_law(IndividualID, TaxpayerID, _))
        )
    ),
    !.
s152_d_2_relationship_is_only_H(_, _, _, _, false).
% Helper from s152, specific for 2(b)(3)(B) to check if 152(d)(2)(H) was met.
% This is a bit of a hack; ideally, s152_d_2_relationship_qr_met would tell us *which* clause was met.
% For now, re-evaluate s152_d_2_H_member_of_household directly.
s152_d_2_H_member_of_household(CaseID, TaxpayerID, IndividualID, TaxYear, true) :- % Copied from section152.pl for direct check
    \+ fact(CaseID, was_spouse_during_year(IndividualID, TaxpayerID, TaxYear)),
    fact(CaseID, principal_place_of_abode_entire_year(IndividualID, TaxpayerID, TaxYear)),
    fact(CaseID, member_of_household_entire_year(IndividualID, TaxpayerID, TaxYear)),
    !.
s152_d_2_H_member_of_household(_, _, _, _, false).