:- module(section152,
          [
            s152_is_dependent/4,            % s152_is_dependent(CaseID, TaxpayerID, PotentialDependentID, TaxYear)
            s152_is_qualifying_child/4,     % s152_is_qualifying_child(CaseID, TaxpayerID, ChildID, TaxYear) - general wrapper
            s152_c_is_qualifying_child_s152c/4, % s152_c_is_qualifying_child_s152c(CaseID, TaxpayerID, ChildID, TaxYear) - specific to s152(c) rules
            s152_is_qualifying_relative/4,  % s152_is_qualifying_relative(CaseID, TaxpayerID, RelativeID, TaxYear)
            s152_c_3_age_requirement_met/4, % s152_c_3_age_requirement_met(CaseID, TaxpayerID, ChildID, TaxYear)
            s152_c_2_A_relationship_met/3,  % s152_c_2_A_relationship_met(CaseID, TaxpayerID, ChildID)
            s152_b_2_applies_married_dependent_joint_return/4 % s152_b_2_applies_married_dependent_joint_return(CaseID, PotentialDependentID, SpouseID, TaxYear)
          ]).

:- use_module(helpers, [age_at_year_end/4, is_younger_than/4]).

% (a) In general
s152_is_dependent(CaseID, TaxpayerID, PotentialDependentID, TaxYear) :-
    \+ s152_b_exceptions_apply(CaseID, TaxpayerID, PotentialDependentID, TaxYear),
    ( s152_is_qualifying_child(CaseID, TaxpayerID, PotentialDependentID, TaxYear)
    ; s152_is_qualifying_relative(CaseID, TaxpayerID, PotentialDependentID, TaxYear)
    ).

% (b) Exceptions
s152_b_exceptions_apply(CaseID, _TaxpayerID, PotentialDependentID, TaxYear) :-
    s152_b_1_dependent_ineligible(CaseID, PotentialDependentID, TaxYear).
s152_b_exceptions_apply(CaseID, _TaxpayerID, PotentialDependentID, TaxYear) :-
    s152_b_2_married_dependent_joint_return(CaseID, PotentialDependentID, TaxYear).

s152_b_1_dependent_ineligible(CaseID, IndividualID, TaxYear) :-
    % If IndividualID is a dependent of SOME taxpayer for a tax year beginning in CalendarYear,
    % IndividualID has no dependents for THEIR tax year beginning in CalendarYear.
    % This is a tie-breaker. Assumes TaxYear is the CalendarYear.
    fact(CaseID, is_dependent_of_another(IndividualID, TaxYear)), % Fact: individual is claimed by someone else
    % This rule is about IndividualID not having THEIR OWN dependents.
    % The current query is s152_is_dependent(CaseID, TaxpayerID, PotentialDependentID, TaxYear),
    % where PotentialDependentID is IndividualID.
    % This rule means if PotentialDependentID is already someone's dependent, they cannot claim others.
    % It does not directly stop PotentialDependentID from BEING a dependent of TaxpayerID, unless
    % it forms part of a tie-breaker rule for QC not explicitly detailed here.
    % The phrasing "such individual shall be treated as having no dependents" is key.
    % For now, this exception is more for when PotentialDependentID tries to claim someone else.
    % Let's assume this means if PotentialDependentID *is* a dependent, they can't BE a QC/QR for someone else *if that implies they have dependents*.
    % This rule is typically part of tie-breaking for QC. The current context might be simpler.
    % For now, not implementing a direct block based on this interpretation here,
    % as it's complex without full tie-breaker rules.
    fail. % Placeholder for more complex tie-breaker logic if needed.

s152_b_2_married_dependent_joint_return(CaseID, PotentialDependentID, TaxYear) :-
    fact(CaseID, spouse_of(PotentialDependentID, SpouseID)), % PotentialDependent has a spouse
    fact(CaseID, filed_joint_return(PotentialDependentID, SpouseID, TaxYear)). % And they filed jointly

% For case s152_b_2_neg:
s152_b_2_applies_married_dependent_joint_return(CaseID, PotentialDependentID, SpouseID, TaxYear) :-
    fact(CaseID, filed_joint_return(PotentialDependentID, SpouseID, TaxYear)).


% (c) Qualifying child - general wrapper, might include tie-breakers not in (c) itself
s152_is_qualifying_child(CaseID, TaxpayerID, ChildID, TaxYear) :-
    s152_c_is_qualifying_child_s152c(CaseID, TaxpayerID, ChildID, TaxYear).
    % And pass any higher-level tie-breakers if they were defined.

% (c) Qualifying child - specific S152(c) rules
s152_c_is_qualifying_child_s152c(CaseID, TaxpayerID, ChildID, TaxYear) :-
    s152_c_1_A_relationship(CaseID, TaxpayerID, ChildID),
    s152_c_1_B_abode(CaseID, TaxpayerID, ChildID, TaxYear),
    s152_c_1_C_age(CaseID, TaxpayerID, ChildID, TaxYear),
    s152_c_1_E_not_filed_joint_return(CaseID, ChildID, TaxYear).
    % (D) support test not in this version of text for QC, but often is. Sticking to text.

s152_c_1_A_relationship(CaseID, TaxpayerID, ChildID) :-
    s152_c_2_relationship_met(CaseID, TaxpayerID, ChildID).

s152_c_1_B_abode(CaseID, TaxpayerID, ChildID, TaxYear) :-
    fact(CaseID, principal_place_of_abode_for_more_than_half_year(ChildID, TaxpayerID, TaxYear)).

s152_c_1_C_age(CaseID, TaxpayerID, ChildID, TaxYear) :-
    s152_c_3_age_requirement_met(CaseID, TaxpayerID, ChildID, TaxYear).

s152_c_1_E_not_filed_joint_return(CaseID, ChildID, TaxYear) :-
    % Child has not filed a joint return with their spouse
    ( \+ fact(CaseID, spouse_of(ChildID, _ChildSpouseID)) % Child not married, so no joint return
    ; ( fact(CaseID, spouse_of(ChildID, ChildSpouseID)),
        \+ fact(CaseID, filed_joint_return(ChildID, ChildSpouseID, TaxYear)) % Married, but didn't file jointly
      )
    ; ( fact(CaseID, spouse_of(ChildID, ChildSpouseID)),
        fact(CaseID, filed_joint_return_only_for_refund(ChildID, ChildSpouseID, TaxYear)) % Filed jointly but only for refund
      )
    ).

s152_c_2_relationship_met(CaseID, TaxpayerID, IndividualID) :- % (A) or (B)
    s152_c_2_A_relationship_met(CaseID, TaxpayerID, IndividualID).
s152_c_2_relationship_met(CaseID, TaxpayerID, IndividualID) :-
    s152_c_2_B_relationship_met(CaseID, TaxpayerID, IndividualID).

s152_c_2_A_relationship_met(CaseID, TaxpayerID, IndividualID) :-
    fact(CaseID, child_of(IndividualID, TaxpayerID)). % Includes adopted
s152_c_2_A_relationship_met(CaseID, TaxpayerID, IndividualID) :-
    fact(CaseID, child_of(DescendantSource, TaxpayerID)),
    fact(CaseID, descendant_of(IndividualID, DescendantSource)). % Grandchild, etc.

s152_c_2_B_relationship_met(CaseID, TaxpayerID, IndividualID) :-
    ( fact(CaseID, brother_of(IndividualID, TaxpayerID))
    ; fact(CaseID, sister_of(IndividualID, TaxpayerID))
    ; fact(CaseID, stepbrother_of(IndividualID, TaxpayerID))
    ; fact(CaseID, stepsister_of(IndividualID, TaxpayerID))
    ).
s152_c_2_B_relationship_met(CaseID, TaxpayerID, IndividualID) :- % Descendant of sibling/stepsibling
    ( fact(CaseID, brother_of(Sibling, TaxpayerID)) ; fact(CaseID, sister_of(Sibling, TaxpayerID)) ;
      fact(CaseID, stepbrother_of(Sibling, TaxpayerID)) ; fact(CaseID, stepsister_of(Sibling, TaxpayerID)) ),
    fact(CaseID, descendant_of(IndividualID, Sibling)). % Niece/nephew etc.

s152_c_3_age_requirement_met(CaseID, TaxpayerID, ChildID, TaxYear) :-
    is_younger_than(CaseID, ChildID, TaxpayerID, TaxYear), % Child younger than taxpayer
    age_at_year_end(CaseID, ChildID, TaxYear, ChildAge),
    ChildAge < 25. % "less than 25 years old at the end of the taxable year" - sticking to text.


% (d) Qualifying relative
s152_is_qualifying_relative(CaseID, TaxpayerID, RelativeID, TaxYear) :-
    s152_d_1_A_relationship(CaseID, TaxpayerID, RelativeID, TaxYear), % Pass TaxYear
    s152_d_1_B_no_income(CaseID, RelativeID, TaxYear),
    s152_d_1_D_not_qc_of_anyone(CaseID, TaxpayerID, RelativeID, TaxYear).

s152_d_1_A_relationship(CaseID, TaxpayerID, RelativeID, TaxYear) :- % Add TaxYear
    s152_d_2_relationship_met(CaseID, TaxpayerID, RelativeID, TaxYear). % Pass TaxYear

% ... other s152_d_2_relationship_met clauses remain the same arity /3 ...
% The specific one for (H) needs to be /4 and others should be adapted or remain /3 if TaxYear not needed.
% For simplicity, let's make all s152_d_2_relationship_met clauses take TaxYear, marking it _TaxYear if unused.

s152_d_2_relationship_met(CaseID, TaxpayerID, IndividualID, _TaxYear) :- % (A)
    ( fact(CaseID, child_of(IndividualID, TaxpayerID)) ; (fact(CaseID, child_of(C, TaxpayerID)), fact(CaseID, descendant_of(IndividualID, C))) ).
s152_d_2_relationship_met(CaseID, TaxpayerID, IndividualID, _TaxYear) :- % (B)
    ( fact(CaseID, brother_of(IndividualID, TaxpayerID)) ; fact(CaseID, sister_of(IndividualID, TaxpayerID)) ;
      fact(CaseID, stepbrother_of(IndividualID, TaxpayerID)) ; fact(CaseID, stepsister_of(IndividualID, TaxpayerID)) ).
s152_d_2_relationship_met(CaseID, TaxpayerID, IndividualID, _TaxYear) :- % (C)
    ( fact(CaseID, father_of(IndividualID, TaxpayerID)) ; fact(CaseID, mother_of(IndividualID, TaxpayerID)) ;
      (fact(CaseID, father_of(P, TaxpayerID)), fact(CaseID, ancestor_of(IndividualID, P))) ;
      (fact(CaseID, mother_of(M, TaxpayerID)), fact(CaseID, ancestor_of(IndividualID, M))) ).
s152_d_2_relationship_met(CaseID, TaxpayerID, IndividualID, _TaxYear) :- % (D)
    ( fact(CaseID, stepfather_of(IndividualID, TaxpayerID)) ; fact(CaseID, stepmother_of(IndividualID, TaxpayerID)) ).
s152_d_2_relationship_met(CaseID, TaxpayerID, IndividualID, _TaxYear) :- % (E)
    ( fact(CaseID, brother_of(Sibling, TaxpayerID)) ; fact(CaseID, sister_of(Sibling, TaxpayerID)) ),
    ( fact(CaseID, son_of(IndividualID, Sibling)) ; fact(CaseID, daughter_of(IndividualID, Sibling)) ).
s152_d_2_relationship_met(CaseID, TaxpayerID, IndividualID, _TaxYear) :- % (F)
    ( fact(CaseID, father_of(Father, TaxpayerID)), (fact(CaseID, brother_of(IndividualID, Father)) ; fact(CaseID, sister_of(IndividualID, Father))) ) ;
    ( fact(CaseID, mother_of(Mother, TaxpayerID)), (fact(CaseID, brother_of(IndividualID, Mother)) ; fact(CaseID, sister_of(IndividualID, Mother))) ).
s152_d_2_relationship_met(CaseID, TaxpayerID, IndividualID, _TaxYear) :- % (G)
    ( fact(CaseID, son_in_law_of(IndividualID, TaxpayerID)) ; fact(CaseID, daughter_in_law_of(IndividualID, TaxpayerID)) ;
      fact(CaseID, father_in_law_of(IndividualID, TaxpayerID)) ; fact(CaseID, mother_in_law_of(IndividualID, TaxpayerID)) ;
      fact(CaseID, brother_in_law_of(IndividualID, TaxpayerID)) ; fact(CaseID, sister_in_law_of(IndividualID, TaxpayerID)) ).
s152_d_2_relationship_met(CaseID, TaxpayerID, IndividualID, TaxYear) :- % (H) - This one uses TaxYear
    \+ fact(CaseID, was_spouse_during_year_s7703(IndividualID, TaxpayerID, TaxYear)), % Correctly use TaxYear
    fact(CaseID, principal_place_of_abode_for_taxable_year(IndividualID, TaxpayerID, TaxYear)),
    fact(CaseID, member_of_taxpayers_household(IndividualID, TaxpayerID, TaxYear)).

% Also update the export list if s152_d_2_relationship_met/4 is intended for external use,
% or ensure it's only called internally. Based on the error, it's an internal logic issue primarily.
% The export list already contains s152_is_qualifying_relative/4 which calls down to these.