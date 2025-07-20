:- module(section151,
          [ personal_exemption_deduction/4,      % personal_exemption_deduction(Taxpayer, CaseID, Year, TotalDeduction)
            is_entitled_to_deduction_for_dependent/4, % is_entitled_to_deduction_for_dependent(Taxpayer, Dependent, CaseID, Year)
            exemption_amount/4                       % exemption_amount(Taxpayer, Year, CaseID, Amount) - §151(d) wrapper
          ]).

:- use_module(tests, [fact/2]).
:- use_module(helpers, [tcja_active_for_tax_year/1, sum_list/2]).
:- use_module(knowledge_base, [exemption_amount/2, phaseout_step/3]).
:- use_module(section152, [is_dependent/4]).
% NOTE: The dependency on section68 is required for the phaseout calculation.
% s151 -> s68 -> s2 -> s151 creates a module dependency cycle, which SWI-Prolog handles.
:- use_module(section68, [applicable_amount/4]).


% §151(a) Main predicate to calculate total deduction for personal exemptions.
personal_exemption_deduction(Taxpayer, CaseID, Year, TotalDeduction) :-
    % The TCJA rule in §151(d)(5) sets the exemption amount to zero, so this predicate
    % will correctly return 0 for years 2018-2025.
    exemption_for_taxpayer(Taxpayer, CaseID, Year, TaxpayerAmount),
    exemption_for_spouse(Taxpayer, CaseID, Year, SpouseAmount),
    exemptions_for_dependents(Taxpayer, CaseID, Year, DependentsAmount),
    TotalDeduction is TaxpayerAmount + SpouseAmount + DependentsAmount.

% §151(c) Wrapper to check eligibility for a dependent deduction.
% This is used by other sections to check status, without needing the amount.
is_entitled_to_deduction_for_dependent(Taxpayer, Dependent, CaseID, Year) :-
    is_dependent(Taxpayer, Dependent, CaseID, Year).

% §151(b) Exemption for taxpayer.
exemption_for_taxpayer(Taxpayer, CaseID, Year, Amount) :-
    exemption_amount(Taxpayer, Year, CaseID, Amount).

% §151(b) Exemption for spouse.
exemption_for_spouse(Taxpayer, CaseID, Year, Amount) :-
    fact(CaseID, spouse(Taxpayer, Spouse)),
    \+ fact(CaseID, files_joint_return(Taxpayer, Spouse, Year)),
    \+ (fact(CaseID, gross_income(Spouse, Year, Inc)), Inc > 0),
    \+ fact(CaseID, is_dependent_of(Spouse, _, Year)), !,
    exemption_amount(Taxpayer, Year, CaseID, Amount).
exemption_for_spouse(_, _, _, 0).

% §151(c) Sum of exemptions for all dependents.
exemptions_for_dependents(Taxpayer, CaseID, Year, TotalDependentsAmount) :-
    findall(Dependent, is_dependent(Taxpayer, Dependent, CaseID, Year), Dependents),
    exemption_amount(Taxpayer, Year, CaseID, AmountPerDependent),
    length(Dependents, NumDependents),
    TotalDependentsAmount is NumDependents * AmountPerDependent.

% §151(d) Exemption Amount Calculation (the core logic).
% This predicate determines the amount for ONE exemption, considering phaseouts.
% The amount is based on the Taxpayer's AGI, not the individual's.
exemption_amount(_Taxpayer, Year, _CaseID, 0) :-
    tcja_active_for_tax_year(Year), !.
exemption_amount(Taxpayer, Year, CaseID, Amount) :-
    \+ tcja_active_for_tax_year(Year),
    % §151(d)(2) Disallowed if individual is a dependent of another.
    % This check applies when calculating the individual's *own* tax return,
    % not when they are being claimed as a dependent. For simplicity in this model,
    % we assume the primary taxpayer is not a dependent of another.
    % The `exemptions_for_dependents` handles dependents correctly.
    knowledge_base:exemption_amount(Year, BaseAmount),
    (   fact(CaseID, adjusted_gross_income(Taxpayer, Year, AGI))
    ->  phaseout_adjusted_amount(Taxpayer, Year, CaseID, AGI, BaseAmount, Amount)
    ;   Amount = BaseAmount % No AGI, no phaseout.
    ).

% §151(d)(3) Phaseout logic.
phaseout_adjusted_amount(Taxpayer, Year, CaseID, AGI, BaseAmount, FinalAmount) :-
    applicable_amount(Taxpayer, CaseID, Year, Threshold),
    AGI > Threshold, !,
    ExcessAGI is AGI - Threshold,
    % Determine filing status to get correct step amount for phaseout
    ( fact(CaseID, files_separate_return(Taxpayer, Year)) -> Status = married_filing_separately ; Status = other ),
    phaseout_step(Year, Status, Step),
    NumSteps is ceil(ExcessAGI / Step),
    ApplicablePercentageRaw is 2 * NumSteps,
    ApplicablePercentage is min(ApplicablePercentageRaw, 100),
    Reduction is BaseAmount * (ApplicablePercentage / 100),
    FinalAmount is max(0, BaseAmount - Reduction).
phaseout_adjusted_amount(_, _, _, _, BaseAmount, BaseAmount). % AGI not over threshold.
