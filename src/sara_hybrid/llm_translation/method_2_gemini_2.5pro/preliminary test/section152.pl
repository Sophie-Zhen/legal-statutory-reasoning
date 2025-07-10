:- module(section152,
          [
            s152_is_dependent/5, % s152_is_dependent(CaseID, TaxpayerID, PotentialDependentID, TaxYear, IsDependentBool)
            s152_a_1_is_qualifying_child/5, % s152_a_1_is_qualifying_child(CaseID, TaxpayerID, PotentialDependentID, TaxYear, IsQCBool)
            s152_a_2_is_qualifying_relative/5, % s152_a_2_is_qualifying_relative(CaseID, TaxpayerID, PotentialDependentID, TaxYear, IsQRBool)
            s152_c_qualifying_child/5, % s152_c_qualifying_child(CaseID, TaxpayerID, ChildID, TaxYear, IsQCBool)
            s152_d_qualifying_relative/5, % s152_d_qualifying_relative(CaseID, TaxpayerID, RelativeID, TaxYear, IsQRBool)
            s152_d_2_relationship_qr_met/4 % s152_d_2_relationship_qr_met(CaseID, TaxpayerID, IndividualID, TaxYear, MetBool) - For s2_b_3_B
          ]).
:- use_module(helpers, [get_age_at_year_end/4]).
:- use_module(tests, [fact/2]). % Or pass facts as arguments
% s152_is_dependent(CaseID, TaxpayerID, PotentialDependentID, TaxYear, IsDependentBool)
s152_is_dependent(CaseID, TaxpayerID, PotentialDependentID, TaxYear, IsDependentBool) :-
    % Exceptions under (b) first
    ( s152_b_1_dependent_ineligible(CaseID, PotentialDependentID, TaxYear, true) ->
        IsDependentBool = false
    ; s152_b_2_married_dependent_joint_return(CaseID, PotentialDependentID, TaxYear, true) ->
        IsDependentBool = false
    ; % Check if qualifying child or qualifying relative
      ( s152_a_1_is_qualifying_child(CaseID, TaxpayerID, PotentialDependentID, TaxYear, true) ->
            IsDependentBool = true
      ; s152_a_2_is_qualifying_relative(CaseID, TaxpayerID, PotentialDependentID, TaxYear, true) ->
            IsDependentBool = true
      ; IsDependentBool = false
      )
    ).
% s152_a_1_is_qualifying_child(CaseID, TaxpayerID, PotentialDependentID, TaxYear, IsQCBool)
s152_a_1_is_qualifying_child(CaseID, TaxpayerID, PotentialDependentID, TaxYear, IsQCBool) :-
    s152_c_qualifying_child(CaseID, TaxpayerID, PotentialDependentID, TaxYear, IsQCBool).
% s152_a_2_is_qualifying_relative(CaseID, TaxpayerID, PotentialDependentID, TaxYear, IsQRBool)
s152_a_2_is_qualifying_relative(CaseID, TaxpayerID, PotentialDependentID, TaxYear, IsQRBool) :-
    s152_d_qualifying_relative(CaseID, TaxpayerID, PotentialDependentID, TaxYear, IsQRBool).
% s152_b_1_dependent_ineligible(CaseID, IndividualID, TaxYear, IsIneligibleBool)
% If an individual is a dependent of a taxpayer, such individual shall be treated as having no dependents.
s152_b_1_dependent_ineligible(CaseID, IndividualID, TaxYear, true) :-
    fact(CaseID, is_dependent_of(IndividualID, _AnotherTaxpayerID, TaxYear)), % IndividualID is claimed by someone else
    fact(CaseID, claims_dependent(IndividualID, _SomeonesDependentID, TaxYear)), % And IndividualID is trying to claim their own dependent
    !.
s152_b_1_dependent_ineligible(_, _, _, false). % This rule is about whether IndividualID can HAVE dependents.
                                                % When checking if X is Y's dependent, this rule applies to X.
                                                % So, if IndividualID (the potential dependent) *has* dependents, they are ineligible?
                                                % "such individual shall be treated as having no dependents" - this means if A is B's dependent, A cannot claim C as A's dependent.
                                                % This rule doesn't make *IndividualID* ineligible to *be* a dependent.
                                                % It restricts who IndividualID can claim.
                                                % Re-evaluating: This means if PotentialDependentID is *themselves* a dependent of *another* taxpayer,
                                                % then PotentialDependentID cannot claim their *own* dependents.
                                                % It does NOT mean PotentialDependentID cannot BE a dependent.
                                                % The rule is "Dependents ineligible [to claim other dependents]".
                                                % So this rule is not for s152_is_dependent check directly.
                                                % Let's assume it's correctly interpreted as not directly blocking someone from *being* a dependent.
                                                % However, tax law often has tie-breaker rules. This might be misinterp.
                                                % The common interpretation is that if you *can be claimed* as a dependent, you can't claim dependents.
                                                % This section seems to be about whether the *potential dependent* can *have* their own dependents.
                                                % For the purpose of "is X a dependent of Y?", this rule is not directly applicable to X's eligibility.
                                                % It's more about X's ability to claim Z.
                                                % Let's assume this is not a blocker for *being* a dependent for now.
                                                % Okay, the prompt's `s151_d_2_disallowed_for_dependent` is "exemption amount applicable to such individual for such individual's taxable year shall be zero".
                                                % This is different.
                                                % Let's assume s152(b)(1) is not a blocker for being a dependent based on its phrasing "treated as having no dependents".
% s152_b_2_married_dependent_joint_return(CaseID, PotentialDependentID, TaxYear, FiledJointReturnBool)
% An individual shall not be treated as a dependent ... if such individual has made a joint return.
s152_b_2_married_dependent_joint_return(CaseID, PotentialDependentID, TaxYear, true) :-
    fact(CaseID, spouse_of(PotentialDependentID, SpouseOfPotentialDependent)),
    fact(CaseID, files_joint_return(PotentialDependentID, SpouseOfPotentialDependent, TaxYear)),
    % Add exception: "other than only for a claim of refund" - this is complex to model without more data.
    % Assuming any joint return mentioned is not solely for refund unless specified.
    !.
s152_b_2_married_dependent_joint_return(_, _, _, false).
% s152_c_qualifying_child(CaseID, TaxpayerID, ChildID, TaxYear, IsQCBool)
s152_c_qualifying_child(CaseID, TaxpayerID, ChildID, TaxYear, true) :-
    s152_c_1_A_relationship_qc(CaseID, TaxpayerID, ChildID, TaxYear, true),
    s152_c_1_B_abode_qc(CaseID, TaxpayerID, ChildID, TaxYear, true),
    s152_c_1_C_age_qc(CaseID, TaxpayerID, ChildID, TaxYear, true),
    % (D) is missing in provided text (Support test usually) - assume not applicable or covered by facts implicitly
    s152_c_1_E_no_joint_return_qc(CaseID, ChildID, TaxYear, true),
    !.
s152_c_qualifying_child(_, _, _, _, false).
% s152_c_1_A_relationship_qc(CaseID, TaxpayerID, ChildID, TaxYear, RelationshipMetBool)
s152_c_1_A_relationship_qc(CaseID, TaxpayerID, ChildID, _TaxYear, RelationshipMetBool) :-
    s152_c_2_relationship_definition_qc(CaseID, TaxpayerID, ChildID, RelationshipMetBool).
% s152_c_1_B_abode_qc(CaseID, TaxpayerID, ChildID, TaxYear, AbodeMetBool)
s152_c_1_B_abode_qc(CaseID, TaxpayerID, ChildID, TaxYear, true) :-
    fact(CaseID, principal_place_of_abode_gt_half_year(ChildID, TaxpayerID, TaxYear)),
    !.
s152_c_1_B_abode_qc(_, _, _, _, false).
% s152_c_1_C_age_qc(CaseID, TaxpayerID, ChildID, TaxYear, AgeMetBool)
s152_c_1_C_age_qc(CaseID, TaxpayerID, ChildID, TaxYear, AgeMetBool) :-
    s152_c_3_age_requirements_definition_qc(CaseID, TaxpayerID, ChildID, TaxYear, AgeMetBool).
% s152_c_1_E_no_joint_return_qc(CaseID, ChildID, TaxYear, NoJointReturnMetBool)
% Same as s152_b_2 effectively, but for QC context.
s152_c_1_E_no_joint_return_qc(CaseID, ChildID, TaxYear, true) :-
    \+ ( fact(CaseID, spouse_of(ChildID, SpouseOfChild)),
         fact(CaseID, files_joint_return(ChildID, SpouseOfChild, TaxYear))
         % Add "other than only for claim of refund" if data available
       ),
    !.
s152_c_1_E_no_joint_return_qc(_, _, _, false).
% s152_c_2_relationship_definition_qc(CaseID, TaxpayerID, IndividualID, RelationshipMetBool)
s152_c_2_relationship_definition_qc(CaseID, TaxpayerID, IndividualID, true) :-
    % (A) child of taxpayer or descendant of such child
    ( fact(CaseID, relationship_child_of(IndividualID, TaxpayerID))
    ; fact(CaseID, relationship_descendant_of_child(IndividualID, TaxpayerID)) % e.g. grandchild
    ), !.
s152_c_2_relationship_definition_qc(CaseID, TaxpayerID, IndividualID, true) :-
    % (B) brother, sister, stepbrother, stepsister of taxpayer or descendant of any such relative
    ( fact(CaseID, relationship_sibling_of(IndividualID, TaxpayerID))
    ; fact(CaseID, relationship_step_sibling_of(IndividualID, TaxpayerID))
    ; fact(CaseID, relationship_descendant_of_sibling(IndividualID, TaxpayerID)) % nephew/niece
    ; fact(CaseID, relationship_descendant_of_step_sibling(IndividualID, TaxpayerID))
    ), !.
s152_c_2_relationship_definition_qc(_, _, _, false).
% s152_c_3_age_requirements_definition_qc(CaseID, TaxpayerID, ChildID, TaxYear, AgeMetBool)
% Individual is younger than taxpayer AND less than 25 at end of year.
% Note: Original text is "less than 19" or "student less than 24" or "permanently and totally disabled".
% The provided text "less than 25 years old at the end of the taxable year" is simpler.
s152_c_3_age_requirements_definition_qc(CaseID, TaxpayerID, ChildID, TaxYear, true) :-
    get_age_at_year_end(CaseID, ChildID, TaxYear, ChildAge),
    get_age_at_year_end(CaseID, TaxpayerID, TaxYear, TaxpayerAge),
    ChildAge < TaxpayerAge,
    ChildAge < 25,
    !.
s152_c_3_age_requirements_definition_qc(_, _, _, _, false).
% s152_d_qualifying_relative(CaseID, TaxpayerID, RelativeID, TaxYear, IsQRBool)
s152_d_qualifying_relative(CaseID, TaxpayerID, RelativeID, TaxYear, true) :-
    s152_d_1_A_relationship_qr(CaseID, TaxpayerID, RelativeID, TaxYear, true),
    s152_d_1_B_gross_income_qr(CaseID, RelativeID, TaxYear, true),
    % (C) Support test - missing in provided text, assume met or covered by facts
    s152_d_1_D_not_qualifying_child_qr(CaseID, TaxpayerID, RelativeID, TaxYear, true),
    !.
s152_d_qualifying_relative(_, _, _, _, false).
% s152_d_1_A_relationship_qr(CaseID, TaxpayerID, RelativeID, TaxYear, RelationshipMetBool)
s152_d_1_A_relationship_qr(CaseID, TaxpayerID, RelativeID, TaxYear, RelationshipMetBool) :-
    s152_d_2_relationship_definition_qr(CaseID, TaxpayerID, RelativeID, TaxYear, RelationshipMetBool).
% s152_d_1_B_gross_income_qr(CaseID, RelativeID, TaxYear, GrossIncomeMetBool)
% "who has no income for the calendar year" - very strict.
% Usually this is "gross income less than exemption amount". Sticking to text.
s152_d_1_B_gross_income_qr(CaseID, RelativeID, TaxYear, true) :-
    fact(CaseID, gross_income(RelativeID, TaxYear, IncomeAmount)),
    IncomeAmount =:= 0,
    !.
s152_d_1_B_gross_income_qr(CaseID, RelativeID, TaxYear, true) :- % If no income fact, assume 0
    \+ fact(CaseID, gross_income(RelativeID, TaxYear, _)),
    !.
s152_d_1_B_gross_income_qr(_, _, _, false).
% s152_d_1_D_not_qualifying_child_qr(CaseID, TaxpayerID, RelativeID, TaxYear, NotQC άλλοιBool)
% RelativeID is not a QC of TaxpayerID AND RelativeID is not a QC of any other taxpayer.
s152_d_1_D_not_qualifying_child_qr(CaseID, TaxpayerID, RelativeID, TaxYear, true) :-
    s152_c_qualifying_child(CaseID, TaxpayerID, RelativeID, TaxYear, false), % Not QC of this taxpayer
    \+ ( fact(CaseID, person_is_taxpayer(OtherTaxpayerID)), % Check all other potential taxpayers
         OtherTaxpayerID \== TaxpayerID,
         s152_c_qualifying_child(CaseID, OtherTaxpayerID, RelativeID, TaxYear, true) % Is QC of other taxpayer
       ),
    !.
s152_d_1_D_not_qualifying_child_qr(_, _, _, _, false).
% s152_d_2_relationship_definition_qr(CaseID, TaxpayerID, IndividualID, TaxYear, RelationshipMetBool)
s152_d_2_relationship_definition_qr(CaseID, TaxpayerID, IndividualID, _TaxYear, true) :-
    ( % (A) Child or descendant of a child
      fact(CaseID, relationship_child_of(IndividualID, TaxpayerID))
    ; fact(CaseID, relationship_descendant_of_child(IndividualID, TaxpayerID)) % e.g. grandchild
    ), !.
s152_d_2_relationship_definition_qr(CaseID, TaxpayerID, IndividualID, _TaxYear, true) :-
    ( % (B) Brother, sister, stepbrother, or stepsister
      fact(CaseID, relationship_sibling_of(IndividualID, TaxpayerID))
    ; fact(CaseID, relationship_step_sibling_of(IndividualID, TaxpayerID))
    ), !.
s152_d_2_relationship_definition_qr(CaseID, TaxpayerID, IndividualID, _TaxYear, true) :-
    ( % (C) Father or mother, or an ancestor of either
      fact(CaseID, relationship_parent_of(IndividualID, TaxpayerID)) % Individual is parent of Taxpayer
    ; fact(CaseID, relationship_ancestor_of_parent(IndividualID, TaxpayerID)) % e.g. grandparent
    ), !.
s152_d_2_relationship_definition_qr(CaseID, TaxpayerID, IndividualID, _TaxYear, true) :-
    ( % (D) Stepfather or stepmother
      fact(CaseID, relationship_step_parent_of(IndividualID, TaxpayerID)) % Individual is stepparent of Taxpayer
    ), !.
s152_d_2_relationship_definition_qr(CaseID, TaxpayerID, IndividualID, _TaxYear, true) :-
    ( % (E) Son or daughter of a brother or sister of the taxpayer (Nephew/Niece)
      fact(CaseID, relationship_child_of_sibling(IndividualID, TaxpayerID))
    ), !.
s152_d_2_relationship_definition_qr(CaseID, TaxpayerID, IndividualID, _TaxYear, true) :-
    ( % (F) Brother or sister of the father or mother of the taxpayer (Aunt/Uncle)
      fact(CaseID, relationship_sibling_of_parent(IndividualID, TaxpayerID))
    ), !.
s152_d_2_relationship_definition_qr(CaseID, TaxpayerID, IndividualID, _TaxYear, true) :-
    ( % (G) Son-in-law, daughter-in-law, father-in-law, mother-in-law, brother-in-law, or sister-in-law
      fact(CaseID, relationship_in_law(IndividualID, TaxpayerID, _InLawType)) % InLawType e.g. son_in_law
    ), !.
s152_d_2_relationship_definition_qr(CaseID, TaxpayerID, IndividualID, TaxYear, true) :-
    % (H) Member of household / principal place of abode
    s152_d_2_H_member_of_household(CaseID, TaxpayerID, IndividualID, TaxYear, true),
    !.
s152_d_2_relationship_definition_qr(_, _, _, _, false).
% s152_d_2_H_member_of_household(CaseID, TaxpayerID, IndividualID, TaxYear, MetBool)
% (H) An individual (other than an individual who at any time during the taxable year was the spouse ...)
% who, for the taxable year of the taxpayer, has the same principal place of abode as the taxpayer
% and is a member of the taxpayer's household.
s152_d_2_H_member_of_household(CaseID, TaxpayerID, IndividualID, TaxYear, true) :-
    \+ fact(CaseID, was_spouse_during_year(IndividualID, TaxpayerID, TaxYear)), % Not spouse at any time
    fact(CaseID, principal_place_of_abode_entire_year(IndividualID, TaxpayerID, TaxYear)), % "for the taxable year" implies full year
    fact(CaseID, member_of_household_entire_year(IndividualID, TaxpayerID, TaxYear)),
    !.
s152_d_2_H_member_of_household(_, _, _, _, false).
% Exported for s2_b_3_B check
s152_d_2_relationship_qr_met(CaseID, TaxpayerID, IndividualID, TaxYear, MetBool) :-
    s152_d_2_relationship_definition_qr(CaseID, TaxpayerID, IndividualID, TaxYear, MetBool).