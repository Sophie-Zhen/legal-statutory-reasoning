:- module(statute_151,
          [ personal_exemption_deduction/5,
            deduction_for_dependent/3
          ]).

/**
 * statute_151.pl
 *
 * This module implements §151, which provides for deductions for personal exemptions.
 *
 * It calculates the total deduction amount by determining the number of exemptions
 * a taxpayer is entitled to and the value of each exemption, which may be phased
 * out at higher income levels. The entire deduction is suspended for years
 * 2018-2025 by the TCJA.
 */

:- use_module(helpers).
:- use_module(knowledge_base).

% The system will provide the 'fact' predicates at runtime.
:- discontiguous fact/1, fact/2, fact/3, fact/4.

% personal_exemption_deduction(+Taxpayer, +Year, +FilingStatus, +AdjustedGrossIncome, -Deduction)
%
% This is the main entry point for calculating the total deduction for personal exemptions.
% It incorporates the TCJA suspension and the income-based phaseout.
personal_exemption_deduction(_Taxpayer, Year, _FilingStatus, _AGI, 0) :-
    helpers:tcja_active_general(Year), !, % §151(d)(5)
    % For years 2018-2025, the exemption amount is zero.
    true.
personal_exemption_deduction(Taxpayer, Year, FilingStatus, AGI, Deduction) :-
    % For other years, calculate the deduction based on the number of exemptions
    % and the per-person amount after any phaseouts.
    get_per_person_exemption_amount(Year, FilingStatus, AGI, PerPersonAmount),
    count_total_exemptions(Taxpayer, Year, FilingStatus, Count),
    Deduction is PerPersonAmount * Count.

% deduction_for_dependent(+Taxpayer, +Individual, +Year)
%
% This predicate serves as a check for other statute modules. It succeeds if
% the Taxpayer is entitled to a deduction for the Individual as a dependent under §151(c).
% The entitlement exists if the individual meets the definition of a dependent in §152.
deduction_for_dependent(Taxpayer, Individual, Year) :-
    statute_152:is_dependent(Taxpayer, Individual, Year, _).

% count_total_exemptions(+Taxpayer, +Year, +FilingStatus, -TotalCount)
%
% Internal helper to count all allowable exemptions: self, spouse, and dependents.
count_total_exemptions(Taxpayer, Year, FilingStatus, TotalCount) :-
    % Taxpayer's own exemption, disallowed if they can be claimed by another (§151(d)(2))
    ( \+ fact(is_dependent_of(Taxpayer, _, Year)) -> SelfCount = 1 ; SelfCount = 0 ),
    % Spouse's exemption (§151(b))
    spouse_exemption_count(Taxpayer, FilingStatus, Year, SpouseCount),
    % Dependents' exemptions (§151(c))
    findall(Dep, deduction_for_dependent(Taxpayer, Dep, Year), Dependents),
    length(Dependents, DependentCount),
    TotalCount is SelfCount + SpouseCount + DependentCount.

% spouse_exemption_count(+Taxpayer, +FilingStatus, +Year, -Count)
%
% Implements the test for the spousal exemption under §151(b).
spouse_exemption_count(Taxpayer, FilingStatus, Year, 1) :-
    FilingStatus \== joint_return,
    fact(spouse_of(Taxpayer, Spouse, Year)),
    fact(has_no_gross_income(Spouse, Year)),
    \+ fact(is_dependent_of(Spouse, _, Year)), !.
spouse_exemption_count(_, _, _, 0).

% get_per_person_exemption_amount(+Year, +FilingStatus, +AGI, -Amount)
%
% Calculates the value of a single exemption after applying the phaseout from §151(d)(3).
get_per_person_exemption_amount(Year, FilingStatus, AGI, FinalAmount) :-
    helpers:get_year_period(Year, Period),
    ( Period == pre_2018 -> knowledge_base:exemption_amount(default, BaseAmount)
    ; BaseAmount = 0
    ),
    get_filing_status_kb_key(FilingStatus, KB_Status),
    knowledge_base:applicable_amount_phaseout(KB_Status, Threshold),
    ( AGI > Threshold ->
        calculate_applicable_percentage(AGI, Threshold, FilingStatus, Percentage),
        Reduction is BaseAmount * Percentage,
        FinalAmount is max(0, BaseAmount - Reduction)
    ; FinalAmount = BaseAmount
    ).

% calculate_applicable_percentage(+AGI, +Threshold, +FilingStatus, -ApplicablePercentage)
%
% Implements the percentage calculation from §151(d)(3)(B).
calculate_applicable_percentage(AGI, Threshold, FilingStatus, ApplicablePercentage) :-
    ( FilingStatus == married_filing_separately -> Divisor = 1250 ; Divisor = 2500 ),
    Excess is AGI - Threshold,
    % Ceiling of integer division: (Numerator + Denominator - 1) / Denominator
    NumIncrements is (Excess + Divisor - 1) // Divisor,
    Percentage is NumIncrements * 0.02,
    ApplicablePercentage is min(1.0, Percentage).

% get_filing_status_kb_key(+FilingStatus, -KB_Status)
%
% Internal helper to map general filing status atoms to knowledge_base keys.
get_filing_status_kb_key(joint_return, joint_return).
get_filing_status_kb_key(surviving_spouse, surviving_spouse).
get_filing_status_kb_key(head_of_household, head_of_household).
get_filing_status_kb_key(unmarried, unmarried).
get_filing_status_kb_key(married_filing_separately, married_filing_separately).