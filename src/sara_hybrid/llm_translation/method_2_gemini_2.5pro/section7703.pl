:- module(section7703,
          [
            s7703_is_married/4, % s7703_is_married(CaseID, TaxpayerID, TaxYear, IsMarriedBool)
            s7703_determination_of_marital_status/4, % s7703_determination_of_marital_status(CaseID, TaxpayerID, TaxYear, MaritalStatusAtom)
                                                     % MaritalStatusAtom: married, not_married, considered_not_married_living_apart
            s7703_b_certain_married_individuals_living_apart/4 % s7703_b_certain_married_individuals_living_apart(CaseID, TaxpayerID, TaxYear, IsConsideredNotMarriedBool)
          ]).
:- use_module(helpers, [get_year_from_date/2]).
:- use_module(tests, [fact/2]). % Assuming facts are in tests.pl, need to ensure this is okay or pass all facts.
                                % For modularity, it's better if facts are queried by the top-level (tests.pl)
                                % and relevant data passed as arguments.
                                % However, the prompt implies statute modules might query facts.
                                % Let's assume for now that direct fact/2 querying is allowed from statute modules
                                % if they declare `:- dynamic fact/2.` and `:- use_module(tests).` or similar.
                                % For cleaner design, tests.pl would query facts and pass them.
                                % Given "No Unnecessary Global State: Rely on argument passing", direct fact querying is less ideal.
                                % I will write it assuming data is passed or use CaseID to query.
% s7703_is_married(CaseID, TaxpayerID, TaxYear, IsMarriedBool)
% Top-level predicate to determine if an individual is considered married for general tax purposes.
% This simplifies to asking if their status is 'married'.
s7703_is_married(CaseID, TaxpayerID, TaxYear, IsMarriedBool) :-
    s7703_determination_of_marital_status(CaseID, TaxpayerID, TaxYear, MaritalStatus),
    ( MaritalStatus == married -> IsMarriedBool = true
    ; IsMarriedBool = false
    ).
% s7703_determination_of_marital_status(CaseID, TaxpayerID, TaxYear, MaritalStatusAtom)
% MaritalStatusAtom can be: married, not_married, considered_not_married_living_apart
s7703_determination_of_marital_status(CaseID, TaxpayerID, TaxYear, MaritalStatus) :-
    s7703_a_general_rule(CaseID, TaxpayerID, TaxYear, StatusByA),
    ( StatusByA == not_married -> MaritalStatus = not_married % If 'not_married' by (a), then (b) is irrelevant for this status.
    ; StatusByA == married ->
        ( s7703_b_certain_married_individuals_living_apart(CaseID, TaxpayerID, TaxYear, true) ->
            MaritalStatus = considered_not_married_living_apart % Treated as not married for certain provisions
        ; MaritalStatus = married % Is married and (b) does not apply or is not relevant here
        )
    ).
% s7703_a_general_rule(CaseID, TaxpayerID, TaxYear, MaritalStatusAtom)
% Determines status based on (a)(1) and (a)(2). Output: married or not_married.
s7703_a_general_rule(CaseID, TaxpayerID, TaxYear, MaritalStatus) :-
    % (a)(2) An individual legally separated... shall not be considered as married. (This takes precedence)
    ( s7703_a_2_legally_separated(CaseID, TaxpayerID, TaxYear, true) ->
        MaritalStatus = not_married
    ; % (a)(1) Determination made as of close of taxable year, or time of death if spouse dies.
      s7703_a_1_determination_timing(CaseID, TaxpayerID, TaxYear, MaritalStatus)
    ).
% s7703_a_1_determination_timing(CaseID, TaxpayerID, TaxYear, MaritalStatusAtom)
% Implements (a)(1).
s7703_a_1_determination_timing(CaseID, TaxpayerID, TaxYear, MaritalStatus) :-
    ( fact(CaseID, spouse_died_during_tax_year(TaxpayerID, _SpouseID, TaxYear)) ->
        % Determination made as of time of death.
        % If they were married at time of death, they are considered married for the year.
        fact(CaseID, married_at_time_of_spouse_death(TaxpayerID, TaxYear)) -> MaritalStatus = married
        % If not married at time of death (e.g. divorced then spouse died), then not_married.
        % This fact needs to be specific. Assume 'married_at_time_of_spouse_death' captures this.
        % If this fact is absent, it implies they were not married at time of death.
        % However, if spouse died, they *were* married to that spouse.
        % The question is if they were married to *anyone* at time of death.
        % For simplicity: if spouse_died_during_tax_year is true, they were married at that point.
      ; fact(CaseID, married_at_close_of_year(TaxpayerID, TaxYear)) -> MaritalStatus = married
      ; MaritalStatus = not_married
    ).
% A more direct interpretation of facts:
s7703_a_1_determination_timing(CaseID, TaxpayerID, TaxYear, married) :-
    fact(CaseID, spouse_of(TaxpayerID, SpouseID)),
    ( fact(CaseID, person_died_on(SpouseID, date(DeathY,_,_))), DeathY == TaxYear
      % If spouse died during year, determination at time of death.
      % Assumed they were married at time of death if they are 'spouse_of'.
      % Need to ensure no remarriage for TaxpayerID if that's relevant here.
      % Sec 7703(a)(1) is about *whether* they are married, not to whom or if they remarried.
    ; \+ fact(CaseID, person_died_on(SpouseID, date(DeathY,_,_))), % Spouse did not die
      fact(CaseID, married_at_close_of_year(TaxpayerID, TaxYear)) % Standard case
    ), !.
s7703_a_1_determination_timing(_CaseID, _TaxpayerID, _TaxYear, not_married).
% s7703_a_2_legally_separated(CaseID, TaxpayerID, TaxYear, IsLegallySeparatedBool)
s7703_a_2_legally_separated(CaseID, TaxpayerID, TaxYear, true) :-
    fact(CaseID, legally_separated_under_decree(TaxpayerID, _SpouseID, TaxYear)), % decree active at year end or time of death
    !.
s7703_a_2_legally_separated(_, _, _, false).
% s7703_b_certain_married_individuals_living_apart(CaseID, TaxpayerID, TaxYear, IsConsideredNotMarriedBool)
% Checks if an individual, though married under (a), is considered not married under (b).
s7703_b_certain_married_individuals_living_apart(CaseID, TaxpayerID, TaxYear, true) :-
    % Condition 0: Individual is married (within meaning of subsection (a)) - checked by caller usually
    % (Implicitly, if we call this, we assume (a) resulted in 'married')
    % Condition 0.5: Files a separate return
    fact(CaseID, files_separate_return(TaxpayerID, TaxYear)),
    % Condition 1: Maintains home for child for >1/2 year, entitled to deduction for child
    s7703_b_1_home_for_child(CaseID, TaxpayerID, TaxYear, true),
    % Condition 2: Furnishes over 1/2 cost of household
    s7703_b_2_furnishes_cost(CaseID, TaxpayerID, TaxYear, true),
    % Condition 3: Spouse not member of household during last 6 months
    s7703_b_3_spouse_not_member(CaseID, TaxpayerID, TaxYear, true),
    !.
s7703_b_certain_married_individuals_living_apart(_, _, _, false).
% s7703_b_1_home_for_child(CaseID, TaxpayerID, TaxYear, HoldsTrueBool)
s7703_b_1_home_for_child(CaseID, TaxpayerID, TaxYear, true) :-
    fact(CaseID, maintains_home_for_child_gt_half_year(TaxpayerID, ChildID, TaxYear)),
    fact(CaseID, entitled_to_deduction_for_child(TaxpayerID, ChildID, TaxYear)), % Deduction under Sec 151
    !.
s7703_b_1_home_for_child(_, _, _, false).
% s7703_b_2_furnishes_cost(CaseID, TaxpayerID, TaxYear, HoldsTrueBool)
s7703_b_2_furnishes_cost(CaseID, TaxpayerID, TaxYear, true) :-
    fact(CaseID, furnished_over_half_cost_of_maintaining_household(TaxpayerID, TaxYear)),
    !.
s7703_b_2_furnishes_cost(_, _, _, false).
% s7703_b_3_spouse_not_member(CaseID, TaxpayerID, TaxYear, HoldsTrueBool)
s7703_b_3_spouse_not_member(CaseID, TaxpayerID, TaxYear, true) :-
    fact(CaseID, spouse_of(TaxpayerID, SpouseID)),
    fact(CaseID, spouse_not_member_of_household_last_6_months(SpouseID, TaxpayerID, TaxYear)), % SpouseID was not member of TaxpayerID's household
    !.
s7703_b_3_spouse_not_member(_, _, _, false).