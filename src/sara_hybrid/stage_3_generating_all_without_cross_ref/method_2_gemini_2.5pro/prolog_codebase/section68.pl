:- module(section68,
          [ itemized_deduction_limitation/5,
            applies_for_year/1,
            applicable_amount_is_for_joint_return/3
          ]).

:- use_module(knowledge_base, [itemized_deduction_limitation_agi_threshold/3]).
:- use_module(helpers, [tcja_active_general/1]).
:- use_module(section2, [is_surviving_spouse/3, is_head_of_household/3, filing_status/4]).
:- use_module(section7703, [is_married/3]).


:- multifile fact/2.

/*
    §68. Overall limitation on itemized deductions
*/

% applies_for_year(Year)
% §68(f) Section does not apply for TCJA years.
applies_for_year(Year) :- \+ tcja_active_general(Year).

% itemized_deduction_limitation(CaseID, Taxpayer, Year, InitialDeductions, FinalDeductions)
% §68(a) General rule.
itemized_deduction_limitation(CaseID, Taxpayer, Year, InitialDeductions, FinalDeductions) :-
    applies_for_year(Year),
    fact(CaseID, adjusted_gross_income(Taxpayer, Year, AGI)),
    filing_status(CaseID, Taxpayer, Year, FilingStatus),
    itemized_deduction_limitation_agi_threshold(Year, FilingStatus, Threshold),
    AGI > Threshold, !,
    ExcessAGI is AGI - Threshold,
    Reduction1 is 0.03 * ExcessAGI,
    Reduction2 is 0.80 * InitialDeductions,
    Reduction is min(Reduction1, Reduction2),
    FinalDeductions is InitialDeductions - Reduction.
itemized_deduction_limitation(_CaseID, _Taxpayer, Year, InitialDeductions, InitialDeductions) :-
    % No limitation applies if AGI is below threshold or section is inactive.
    ( \+ applies_for_year(Year) ; true ).

% applicable_amount_is_for_joint_return(CaseID, Taxpayer, Year)
% §68(b)(1)(A)
applicable_amount_is_for_joint_return(CaseID, Taxpayer, Year) :-
    (   fact(CaseID, files_joint_return(Taxpayer, _, Year))
    ;   is_surviving_spouse(CaseID, Taxpayer, Year)
    ).
