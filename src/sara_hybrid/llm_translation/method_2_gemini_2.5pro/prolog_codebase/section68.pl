:- module(section68,
          [ limited_itemized_deductions/4, % limited_itemized_deductions(Taxpayer, CaseID, Year, FinalDeductions)
            applicable_amount/4            % applicable_amount(Taxpayer, CaseID, Year, Amount)
          ]).

:- use_module(tests, [fact/2]).
:- use_module(helpers, [tcja_active_for_tax_year/1]).
:- use_module(knowledge_base, [phaseout_threshold/3]).
% NOTE: The dependency on section2 is required to get the filing status.
% s68 -> s2 -> s151 -> s68 creates a module dependency cycle, which SWI-Prolog handles.
:- use_module(section2, [filing_status/4]).


% §68(f) This section does not apply to years 2018-2025.
limited_itemized_deductions(_Taxpayer, CaseID, Year, InitialDeductions) :-
    tcja_active_for_tax_year(Year), !,
    (fact(CaseID, itemized_deductions(_Taxpayer, Year, InitialDeductions)) -> true ; InitialDeductions = 0).

% §68(a) General rule for limiting itemized deductions.
limited_itemized_deductions(Taxpayer, CaseID, Year, FinalDeductions) :-
    \+ tcja_active_for_tax_year(Year),
    fact(CaseID, itemized_deductions(Taxpayer, Year, InitialDeductions)),
    fact(CaseID, adjusted_gross_income(Taxpayer, Year, AGI)),
    applicable_amount(Taxpayer, CaseID, Year, Threshold),
    (   AGI > Threshold
    ->  Excess is AGI - Threshold,
        Reduction1 is 0.03 * Excess,
        Reduction2 is 0.80 * InitialDeductions,
        Reduction is min(Reduction1, Reduction2),
        FinalDeductions is InitialDeductions - Reduction
    ;   FinalDeductions = InitialDeductions
    ).
limited_itemized_deductions(Taxpayer, CaseID, Year, 0) :-
    \+ fact(CaseID, itemized_deductions(Taxpayer, Year, _)).


% §68(b) Applicable amount.
% Determines the AGI threshold for the limitation based on filing status.
applicable_amount(Taxpayer, CaseID, Year, Amount) :-
    filing_status(Taxpayer, CaseID, Year, Status),
    (   knowledge_base:phaseout_threshold(Year, Status, Amt)
    ->  Amount = Amt
    % Fallback for married_filing_separately which has a calculated threshold
    ;   Status == married_filing_separately,
        knowledge_base:phaseout_threshold(Year, married_filing_jointly, JointAmt),
        Amount is JointAmt / 2
    ).
