:- module(section151,
    [
        personal_exemption_deduction/4,
        is_entitled_to_deduction/4
    ]).

:- use_module(knowledge_base, [personal_exemption_amount/2, phaseout_step_amount/2]).
:- use_module(helpers, [tcja_active_general/1]).
:- use_module(section152, [is_dependent/4]).
:- use_module(section68, [applicable_amount/4]).
:- use_module(library(lists), [sum_list/2]).

:- multifile fact/2.

personal_exemption_deduction(_CaseID, _Taxpayer, Year, 0) :-
    tcja_active_general(Year), !.
personal_exemption_deduction(CaseID, Taxpayer, Year, TotalDeduction) :-
    \+ tcja_active_general(Year),
    exemption_amount(CaseID, Taxpayer, Year, ExemptionAmount),
    count_exemptions(CaseID, Taxpayer, Year, NumExemptions),
    TotalDeduction is NumExemptions * ExemptionAmount.

is_entitled_to_deduction(CaseID, Taxpayer, Dependent, Year) :-
    is_dependent(CaseID, Taxpayer, Dependent, Year).

count_exemptions(CaseID, Taxpayer, Year, NumExemptions) :-
    taxpayer_exemption_count(CaseID, Taxpayer, Year, TaxpayerCount),
    spouse_exemption_count(CaseID, Taxpayer, Year, SpouseCount),
    dependent_exemption_count(CaseID, Taxpayer, Year, DependentCount),
    NumExemptions is TaxpayerCount + SpouseCount + DependentCount.

taxpayer_exemption_count(CaseID, Taxpayer, Year, 0) :-
    fact(CaseID, is_dependent_of(Taxpayer, _Other, Year)), !.
taxpayer_exemption_count(_CaseID, _Taxpayer, _Year, 1).

spouse_exemption_count(CaseID, Taxpayer, Year, 1) :-
    (fact(CaseID, married(Taxpayer, Spouse, _)); fact(CaseID, married(Spouse, Taxpayer, _))),
    fact(CaseID, files_separate_return(Taxpayer, Year)),
    \+ (fact(CaseID, gross_income(Spouse, Year, Income)), Income > 0),
    \+ fact(CaseID, is_dependent_of(Spouse, _Other, Year)), !.
spouse_exemption_count(_CaseID, _Taxpayer, _Year, 0).

dependent_exemption_count(CaseID, Taxpayer, Year, Count) :-
    findall(Dep, is_dependent(CaseID, Taxpayer, Dep, Year), Dependents),
    length(Dependents, Count).

exemption_amount(CaseID, Taxpayer, Year, FinalAmount) :-
    fact(CaseID, gross_income(Taxpayer, Year, AGI)), % Assuming GI = AGI
    fact(CaseID, filing_status(Taxpayer, Year, FilingStatus)),
    applicable_amount(CaseID, Taxpayer, Year, PhaseoutThreshold),
    AGI > PhaseoutThreshold,
    !,
    personal_exemption_amount(Year, BaseAmount),
    ExcessAGI is AGI - PhaseoutThreshold,
    phaseout_step_amount(FilingStatus, StepAmount),
    ReductionSteps is ceil(ExcessAGI / StepAmount),
    ApplicablePercentage is min(1.0, ReductionSteps * 0.02),
    FinalAmount is BaseAmount * (1 - ApplicablePercentage).
exemption_amount(_CaseID, _Taxpayer, Year, BaseAmount) :-
    personal_exemption_amount(Year, BaseAmount).
