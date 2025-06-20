:- module(section7703,
          [
            s7703_is_married/3,             % s7703_is_married(CaseID, TaxpayerID, TaxYear) -> general determination
            s7703_is_married_gen_rule/3,    % s7703_is_married_gen_rule(CaseID, TaxpayerID, TaxYear) -> specific to (a)
            s7703_is_legally_separated/3,   % s7703_is_legally_separated(CaseID, TaxpayerID, TaxYear)
            s7703_a_1_applies/3             % s7703_a_1_applies(CaseID, TaxpayerID, TaxYear)
          ]).

:- use_module(section151, [s151_is_entitled_to_deduction_for_dependent/4]). % For (b)

% Top-level marital status determination
s7703_is_married(CaseID, TaxpayerID, TaxYear) :-
    s7703_is_married_gen_rule(CaseID, TaxpayerID, TaxYear),
    \+ s7703_b_considered_not_married_living_apart(CaseID, TaxpayerID, TaxYear). % (b) can override (a)

% (a) General rule
s7703_is_married_gen_rule(CaseID, TaxpayerID, TaxYear) :-
    fact(CaseID, is_married_at_determination_time(TaxpayerID, TaxYear)), % Fact representing actual marriage at correct time
    \+ s7703_a_2_legally_separated(CaseID, TaxpayerID, TaxYear).

% s7703_a_1_applies is true if the rules of 7703(a)(1) are used for determination.
% This is always true if marital status is being determined for TaxYear for TaxpayerID.
s7703_a_1_applies(_CaseID, _TaxpayerID, _TaxYear).

s7703_a_2_legally_separated(CaseID, TaxpayerID, TaxYear) :-
    fact(CaseID, legally_separated_by_decree(TaxpayerID, TaxYear)).

% For export to Sec 2
s7703_is_legally_separated(CaseID, TaxpayerID, TaxYear) :-
    s7703_a_2_legally_separated(CaseID, TaxpayerID, TaxYear).

% (b) Certain married individuals living apart
% This rule is for "those provisions of this title which refer to this subsection".
% E.g., Head of Household status.
s7703_b_considered_not_married_living_apart(CaseID, TaxpayerID, TaxYear) :-
    fact(CaseID, referred_to_s7703b(CurrentProvision)), % Check if current context refers to 7703(b)
    CurrentProvision = true, % If the calling rule makes use of this.
    s7703_is_married_gen_rule(CaseID, TaxpayerID, TaxYear), % (1) individual who is married (within meaning of (a))
    fact(CaseID, files_separate_return(TaxpayerID, TaxYear)),
    fact(CaseID, child_for_s7703b(ChildID, TaxpayerID, TaxYear)), % A child for whom taxpayer is entitled to deduction
    s151_is_entitled_to_deduction_for_dependent(CaseID, TaxpayerID, ChildID, TaxYear),
    fact(CaseID, maintains_home_principal_place_of_abode_child_half_year_s7703b(TaxpayerID, ChildID, TaxYear)),
    fact(CaseID, furnishes_over_half_cost_maintaining_household_s7703b(TaxpayerID, TaxYear)), % (2)
    fact(CaseID, spouse_not_member_of_household_last_6_months_s7703b(TaxpayerID, TaxYear)). % (3)