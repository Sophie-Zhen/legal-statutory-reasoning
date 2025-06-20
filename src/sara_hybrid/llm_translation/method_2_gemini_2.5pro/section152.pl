:- module(section152,
          [ s152_is_dependent/4,            % s152_is_dependent(CaseID, TaxpayerID, PotentialDependentID, TaxYear)
            s152_c_is_qualifying_child/4,   % s152_c_is_qualifying_child(CaseID, TaxpayerID, ChildID, TaxYear)
            s152_d_is_qualifying_relative/4,% s152_d_is_qualifying_relative(CaseID, TaxpayerID, RelativeID, TaxYear)
            s152_c_3_age_requirement_met/5, % s152_c_3_age_requirement_met(CaseID, TaxpayerID, ChildID, TaxYear, IsMetBool)
            s152_c_2_A_relationship_child_descendant/3, % s152_c_2_A_relationship_child_descendant(CaseID, TaxpayerID, IndividualID)
            s152_b_2_exception_married_dependent_joint_return/4 % s152_b_2_exception_married_dependent_joint_return(CaseID, PotentialDependentID, TaxYear, AppliesBool)
          ]).

:- use_module(helpers, [get_age_at_year_end/4, is_person_younger_than_person_at_year_end/5]).

:- dynamic fact/2.

% §152(a) In general
s152_is_dependent(CaseID, TaxpayerID, PotentialDependentID, TaxYear) :-
    \+ s152_b_1_exception_dependents_ineligible(CaseID, PotentialDependentID, TaxYear, _), % Pass _ for AppliesBool
    \+ s152_b_2_exception_married_dependent_joint_return(CaseID, PotentialDependentID, TaxYear, true),
    (   s152_c_is_qualifying_child(CaseID, TaxpayerID, PotentialDependentID, TaxYear)
    ;   s152_d_is_qualifying_relative(CaseID, TaxpayerID, PotentialDependentID, TaxYear)
    ).

% §152(b)(1) Dependents ineligible
s152_b_1_exception_dependents_ineligible(CaseID, IndividualID, TaxYear, true) :-
    fact(CaseID, is_dependent_of_another_taxpayer(IndividualID, TaxYear, _SomeOtherTaxpayerID)).
s152_b_1_exception_dependents_ineligible(_, _, _, false).

% §152(b)(2) Married dependents
s152_b_2_exception_married_dependent_joint_return(CaseID, PotentialDependentID, TaxYear, true) :-
    fact(CaseID, spouse_of(PotentialDependentID, SpouseID)),
    fact(CaseID, files_joint_return(PotentialDependentID, SpouseID, TaxYear)).
s152_b_2_exception_married_dependent_joint_return(_, _, _, false).

% §152(c) Qualifying child
s152_c_is_qualifying_child(CaseID, TaxpayerID, ChildID, TaxYear) :-
    s152_c_1_A_relationship(CaseID, TaxpayerID, ChildID),
    s152_c_1_B_abode(CaseID, TaxpayerID, ChildID, TaxYear),
    s152_c_1_C_age(CaseID, TaxpayerID, ChildID, TaxYear, true),
    s152_c_1_E_not_filed_joint_return(CaseID, ChildID, TaxYear).

s152_c_1_A_relationship(CaseID, TaxpayerID, IndividualID) :-
    (s152_c_2_A_relationship_child_descendant(CaseID, TaxpayerID, IndividualID) ;
     s152_c_2_B_relationship_sibling_step_descendant(CaseID, TaxpayerID, IndividualID)).

s152_c_1_B_abode(CaseID, TaxpayerID, ChildID, TaxYear) :-
    fact(CaseID, principal_place_of_abode_more_than_half_year(ChildID, TaxpayerID, TaxYear)).

s152_c_1_C_age(CaseID, TaxpayerID, ChildID, TaxYear, IsMetBool) :-
    s152_c_3_age_requirement_met(CaseID, TaxpayerID, ChildID, TaxYear, IsMetBool).

s152_c_1_E_not_filed_joint_return(CaseID, ChildID, TaxYear) :-
    \+ (fact(CaseID, spouse_of(ChildID, ChildSpouseID)),
        fact(CaseID, files_joint_return(ChildID, ChildSpouseID, TaxYear)),
        \+ fact(CaseID, joint_return_filed_only_for_refund(ChildID, ChildSpouseID, TaxYear))
       ).

% §152(c)(2) Relationship
s152_c_2_A_relationship_child_descendant(CaseID, TaxpayerID, IndividualID) :-
    ( fact(CaseID, relationship_child_of(IndividualID, TaxpayerID)) % Includes adopted
    ; (fact(CaseID, relationship_child_of(Child, TaxpayerID)), fact(CaseID, relationship_descendant_of(IndividualID, Child)))
    ).
s152_c_2_B_relationship_sibling_step_descendant(CaseID, TaxpayerID, IndividualID) :-
    ( fact(CaseID, relationship_sibling_of(IndividualID, TaxpayerID)) % brother, sister
    ; fact(CaseID, relationship_step_sibling_of(IndividualID, TaxpayerID)) % stepbrother, stepsister
    ; ( (fact(CaseID, relationship_sibling_of(Sibling, TaxpayerID)); fact(CaseID, relationship_step_sibling_of(Sibling, TaxpayerID))),
        fact(CaseID, relationship_descendant_of(IndividualID, Sibling)) )
    ).

% §152(c)(3) Age requirements
s152_c_3_age_requirement_met(CaseID, TaxpayerID, ChildID, TaxYear, true) :-
    is_person_younger_than_person_at_year_end(CaseID, ChildID, TaxpayerID, TaxYear, true),
    get_age_at_year_end(CaseID, ChildID, TaxYear, ChildAge),
    ChildAge < 25.
s152_c_3_age_requirement_met(_, _, _, _, false).


% §152(d) Qualifying relative
s152_d_is_qualifying_relative(CaseID, TaxpayerID, RelativeID, TaxYear) :-
    s152_d_1_A_relationship(CaseID, TaxpayerID, RelativeID, TaxYear),
    s152_d_1_B_income_limit(CaseID, RelativeID, TaxYear), % "no income"
    s152_d_1_D_not_qualifying_child(CaseID, TaxpayerID, RelativeID, TaxYear).

s152_d_1_A_relationship(CaseID, TaxpayerID, IndividualID, TaxYear) :-
    s152_d_2_relationship_list(CaseID, TaxpayerID, IndividualID, TaxYear). % Check against any in list (A)-(H)

s152_d_1_B_income_limit(CaseID, RelativeID, TaxYear) :-
    \+ (fact(CaseID, gross_income(RelativeID, TaxYear, GI)), GI > 0).

s152_d_1_D_not_qualifying_child(CaseID, TaxpayerID, RelativeID, TaxYear) :-
    \+ s152_c_is_qualifying_child(CaseID, TaxpayerID, RelativeID, TaxYear), % Not QC of this taxpayer
    \+ fact(CaseID, is_qualifying_child_of_another_taxpayer(RelativeID, TaxYear, _OtherTaxpayer)).

% §152(d)(2) Relationship list for QR
s152_d_2_relationship_list(CaseID, TaxpayerID, IndividualID, TaxYear) :- fact(CaseID, relationship_child_of(IndividualID, TaxpayerID)). % (A) Child
s152_d_2_relationship_list(CaseID, TaxpayerID, IndividualID, TaxYear) :- fact(CaseID, relationship_descendant_of_child(IndividualID, TaxpayerID)). % (A) Descendant of child
s152_d_2_relationship_list(CaseID, TaxpayerID, IndividualID, TaxYear) :- fact(CaseID, relationship_sibling_of(IndividualID, TaxpayerID)). % (B) Brother, sister
s152_d_2_relationship_list(CaseID, TaxpayerID, IndividualID, TaxYear) :- fact(CaseID, relationship_step_sibling_of(IndividualID, TaxpayerID)). % (B) Stepbrother, stepsister
s152_d_2_relationship_list(CaseID, TaxpayerID, IndividualID, TaxYear) :- fact(CaseID, relationship_parent_of(IndividualID, TaxpayerID)). % (C) Father, mother
s152_d_2_relationship_list(CaseID, TaxpayerID, IndividualID, TaxYear) :- fact(CaseID, relationship_ancestor_of_parent(IndividualID, TaxpayerID)). % (C) Ancestor of parent
s152_d_2_relationship_list(CaseID, TaxpayerID, IndividualID, TaxYear) :- fact(CaseID, relationship_stepparent_of(IndividualID, TaxpayerID)). % (D) Stepfather, stepmother
s152_d_2_relationship_list(CaseID, TaxpayerID, IndividualID, TaxYear) :- fact(CaseID, relationship_child_of_sibling(IndividualID, TaxpayerID)). % (E) Niece, nephew
s152_d_2_relationship_list(CaseID, TaxpayerID, IndividualID, TaxYear) :- fact(CaseID, relationship_sibling_of_parent(IndividualID, TaxpayerID)). % (F) Aunt, uncle
s152_d_2_relationship_list(CaseID, TaxpayerID, IndividualID, TaxYear) :- fact(CaseID, relationship_in_law(IndividualID, TaxpayerID, _InLawType)). % (G) In-laws (son-, daughter-, father-, mother-, brother-, sister-in-law)
s152_d_2_relationship_list(CaseID, TaxpayerID, IndividualID, TaxYear) :- % (H) Member of household
    \+ fact(CaseID, was_spouse_anytime_during_year_s7703(IndividualID, TaxpayerID, TaxYear)),
    fact(CaseID, same_principal_place_of_abode_as_taxpayer(IndividualID, TaxpayerID, TaxYear)),
    fact(CaseID, is_member_of_taxpayers_household(IndividualID, TaxpayerID, TaxYear)).