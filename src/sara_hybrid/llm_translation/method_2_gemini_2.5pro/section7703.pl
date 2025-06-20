:- module(section7703,
          [ s7703_is_married/4,               % s7703_is_married(CaseID, TaxpayerID, TaxYear, IsMarriedBool)
            s7703_is_legally_separated/4,     % s7703_is_legally_separated(CaseID, TaxpayerID, TaxYear, IsSeparatedBool)
            s7703_a_1_general_rule_applies/3  % s7703_a_1_general_rule_applies(CaseID, TaxpayerID, TaxYear) - for case question
          ]).

:- use_module(section151, [s151_is_entitled_to_deduction_for_person/4]).

:- dynamic fact/2.

% Top-level determination, considering (b) override
s7703_is_married(CaseID, TaxpayerID, TaxYear, false) :- % Considered not married if (b) applies
    s7703_b_certain_married_living_apart_not_married(CaseID, TaxpayerID, TaxYear, true).
s7703_is_married(CaseID, TaxpayerID, TaxYear, IsMarriedBool) :- % Otherwise, use general rule (a)
    \+ s7703_b_certain_married_living_apart_not_married(CaseID, TaxpayerID, TaxYear, true),
    s7703_a_general_rule_is_married(CaseID, TaxpayerID, TaxYear, IsMarriedBool).

% §7703(a) General rule
s7703_a_general_rule_is_married(CaseID, TaxpayerID, TaxYear, false) :- % (a)(2) Legally separated
    s7703_is_legally_separated(CaseID, TaxpayerID, TaxYear, true).
s7703_a_general_rule_is_married(CaseID, TaxpayerID, TaxYear, true) :- % (a)(1) Determination time
    \+ s7703_is_legally_separated(CaseID, TaxpayerID, TaxYear, true),
    (   fact(CaseID, spouse_of(TaxpayerID, SpouseID)),
        fact(CaseID, date_of_death(SpouseID, date(DeathYear, _, _))), DeathYear =:= TaxYear
    ->  fact(CaseID, is_married_at_time_of_spouse_death(TaxpayerID, TaxYear)) % Married at time of death
    ;   fact(CaseID, is_married_at_close_of_year(TaxpayerID, TaxYear)) % Married at year-end
    ).
s7703_a_general_rule_is_married(_, _, _, false). % Default if not proven true by above

s7703_a_1_general_rule_applies(_CaseID, _TaxpayerID, _TaxYear). % This rule is always the basis for (a)

s7703_is_legally_separated(CaseID, TaxpayerID, TaxYear, true) :-
    fact(CaseID, legally_separated_by_decree_of_divorce_or_separate_maintenance(TaxpayerID, TaxYear)).
s7703_is_legally_separated(_, _, _, false).

% §7703(b) Certain married individuals living apart
s7703_b_certain_married_living_apart_not_married(CaseID, TaxpayerID, TaxYear, true) :-
    fact(CaseID, provision_refers_to_s7703b_for_marital_status(TaxYear)), % e.g. HoH status determination context
    s7703_a_general_rule_is_married(CaseID, TaxpayerID, TaxYear, true), % (1) Married under (a)
    fact(CaseID, files_separate_return(TaxpayerID, TaxYear)),
    fact(CaseID, maintains_home_for_child_s7703b(TaxpayerID, ChildID, TaxYear)), % (1) Home for child > 1/2 year
    s151_is_entitled_to_deduction_for_person(CaseID, TaxpayerID, ChildID, TaxYear),
    fact(CaseID, furnished_over_half_cost_maintaining_household_s7703b(TaxpayerID, TaxYear)), % (2)
    fact(CaseID, spouse_not_member_of_household_last_6_months(TaxpayerID, TaxYear)). % (3)
s7703_b_certain_married_living_apart_not_married(_, _, _, false).