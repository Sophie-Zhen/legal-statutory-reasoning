:- module(section151,
          [ total_personal_exemption_deduction/4,
            is_entitled_to_exemption_deduction/4,
            exemption_amount/4
          ]).

:- use_module(knowledge_base, [exemption_amount_default/2, exemption_phaseout_increment/2]).
:- use_module(section152, [is_dependent/4]).
:- use_module(helpers, [tcja_active_general/1]).

:- multifile fact/2.

/*
    §151. Allowance of deductions for personal exemptions
*/

% total_personal_exemption_deduction(CaseID, Taxpayer, Year, TotalDeduction)
% §151(a) Sum of all allowable exemptions.
total_personal_exemption_deduction(CaseID, Taxpayer, Year, TotalDeduction) :-
    findall(Exemption,
            (   is_entitled_to_exemption_deduction(CaseID, Taxpayer, Taxpayer, Year, Exemption)
            ;   is_entitled_to_exemption_deduction(CaseID, Taxpayer, Spouse, Year, Exemption),
                fact(CaseID, spouse_of(Taxpayer, Spouse)),
                is_spouse_exemption_allowed(CaseID, Taxpayer, Spouse, Year)
            ;   is_entitled_to_exemption_deduction(CaseID, Taxpayer, Dependent, Year, Exemption),
                is_dependent(CaseID, Taxpayer, Dependent, Year)
            ),
            Exemptions),
    sum_list(Exemptions, TotalDeduction).

% is_entitled_to_exemption_deduction(CaseID, Taxpayer, ForWhom, Year, Exemption)
% Determines if Taxpayer gets an exemption for ForWhom and calculates its amount.
is_entitled_to_exemption_deduction(CaseID, Taxpayer, ForWhom, Year, Exemption) :-
    % §151(b) Taxpayer
    ForWhom == Taxpayer,
    exemption_amount(CaseID, Taxpayer, ForWhom, Year, Exemption).
is_entitled_to_exemption_deduction(CaseID, Taxpayer, ForWhom, Year, Exemption) :-
    % §151(b) Spouse
    fact(CaseID, spouse_of(Taxpayer, ForWhom)),
    is_spouse_exemption_allowed(CaseID, Taxpayer, ForWhom, Year),
    exemption_amount(CaseID, Taxpayer, ForWhom, Year, Exemption).
is_entitled_to_exemption_deduction(CaseID, Taxpayer, ForWhom, Year, Exemption) :-
    % §151(c) Dependent
    is_dependent(CaseID, Taxpayer, ForWhom, Year),
    exemption_amount(CaseID, Taxpayer, ForWhom, Year, Exemption).

% is_spouse_exemption_allowed(CaseID, Taxpayer, Spouse, Year)
% §151(b) Rules for claiming an exemption for a spouse.
is_spouse_exemption_allowed(CaseID, Taxpayer, Spouse, Year) :-
    \+ fact(CaseID, files_joint_return(Taxpayer, Spouse, Year)),
    ( \+ fact(CaseID, gross_income(Spouse, Year, _)) ; fact(CaseID, gross_income(Spouse, Year, 0)) ),
    \+ is_dependent(CaseID, _AnotherTaxpayer, Spouse, Year).

% exemption_amount(CaseID, Taxpayer, ForWhom, Year, Amount)
% §151(d) Determines the value of a single exemption.
exemption_amount(_CaseID, _Taxpayer, ForWhom, Year, 0) :-
    % §151(d)(2) Disallowed if ForWhom can be claimed by another.
    tcja_inactive_general(Year),
    fact(_CaseID, claimed_as_dependent_by(ForWhom, _Other, Year)).
exemption_amount(CaseID, Taxpayer, ForWhom, Year, Amount) :-
    % §151(d)(1),(3),(5)
    tcja_inactive_general(Year),
    \+ fact(CaseID, claimed_as_dependent_by(ForWhom, _Other, Year)),
    exemption_amount_default(Year, BaseAmount),
    phaseout_reduction(CaseID, Taxpayer, Year, Reduction),
    Amount is max(0, BaseAmount - Reduction).
exemption_amount(_CaseID, _Taxpayer, _ForWhom, Year, 0) :-
    % §151(d)(5) TCJA rule
    tcja_active_general(Year).

% phaseout_reduction(CaseID, Taxpayer, Year, Reduction)
% §151(d)(3) Phaseout of exemption amount.
% This is complex and relies on §68 which is not fully modeled.
% Simplified: no phaseout for now.
phaseout_reduction(_CaseID, _Taxpayer, _Year, 0).
% A more complete implementation would look like this:
/*
phaseout_reduction(CaseID, Taxpayer, Year, Reduction) :-
    fact(CaseID, adjusted_gross_income(Taxpayer, Year, AGI)),
    filing_status(CaseID, Taxpayer, Year, FilingStatus),
    itemized_deduction_limitation_agi_threshold(Year, FilingStatus, Threshold), % Re-using §68 thresholds
    AGI > Threshold, !,
    exemption_phaseout_increment(FilingStatus, Increment),
    ExcessAGI is AGI - Threshold,
    NumIncrements is ceil(ExcessAGI / Increment),
    ApplicablePercentage is min(1.0, NumIncrements * 0.02),
    exemption_amount_default(Year, BaseAmount),
    Reduction is BaseAmount * ApplicablePercentage.
phaseout_reduction(_, _, _, 0).
*/
