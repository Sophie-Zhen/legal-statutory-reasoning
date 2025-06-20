:- module(section151,
          [
            s151_total_personal_exemptions_deduction/4,
            s151_is_entitled_to_deduction_for_dependent/4,
            s151_is_allowable_as_dependent_to_another/3,
            s151_d_3_B_applicable_percentage/4
          ]).

:- use_module(section152, [s152_is_dependent/4]).
:- use_module(section68, [s68_b_applicable_amount/4]).
:- use_module(helpers, [tcja_active/1]).
% :- use_module(library(math)). % REMOVE THIS LINE - ceil/1 is a built-in arithmetic function

% (a) Allowance of deductions
s151_total_personal_exemptions_deduction(CaseID, TaxpayerID, TaxYear, TotalExemptionAmount) :-
    s151_d_exemption_amount_per_person(CaseID, TaxpayerID, TaxYear, SingleExemptionAmount),
    s151_count_exemptions(CaseID, TaxpayerID, TaxYear, NumberOfExemptions),
    TotalExemptionAmount is NumberOfExemptions * SingleExemptionAmount.

% Counts exemptions: taxpayer, spouse (if applicable), dependents
s151_count_exemptions(CaseID, TaxpayerID, TaxYear, Count) :-
    % Exemption for taxpayer
    ( s151_d_2_disallowed_for_own_exemption(CaseID, TaxpayerID, TaxYear) -> TaxpayerExemptions = 0 ; TaxpayerExemptions = 1 ),
    % Exemption for spouse
    s151_b_spouse_exemption_count(CaseID, TaxpayerID, TaxYear, SpouseExemptions),
    % Exemptions for dependents
    s151_c_dependents_exemption_count(CaseID, TaxpayerID, TaxYear, DependentExemptions),
    Count is TaxpayerExemptions + SpouseExemptions + DependentExemptions.

% (b) Taxpayer and spouse exemption
s151_b_spouse_exemption_count(CaseID, TaxpayerID, TaxYear, 1) :-
    fact(CaseID, spouse_of(TaxpayerID, SpouseID)),
    \+ fact(CaseID, files_joint_return(TaxpayerID, SpouseID, TaxYear)),
    \+ (fact(CaseID, gross_income(SpouseID, TaxYear, GI)), GI > 0), % CORRECTED: remove 'where', use comma and parenthesis for grouping
    \+ s152_is_dependent_of_another_taxpayer(CaseID, SpouseID, TaxYear).
s151_b_spouse_exemption_count(_, _, _, 0). % CORRECTED: Remove singleton 'Otherwise.'
                                         % This is the catch-all if the above clause fails.

% (c) Additional exemption for dependents
s151_c_dependents_exemption_count(CaseID, TaxpayerID, TaxYear, Count) :-
    findall(DepID, s152_is_dependent(CaseID, TaxpayerID, DepID, TaxYear), Dependents),
    length(Dependents, Count).

% (d) Exemption amount
s151_d_exemption_amount_per_person(CaseID, TaxpayerID, TaxYear, ExemptionAmount) :-
    ( tcja_active(TaxYear) -> % (d)(5) Special rules for 2018-2025
        ExemptionAmount = 0
    ; % Pre-2018 rules
        BaseAmount = 2000, % (d)(1) In general
        ( s151_d_3_phaseout_applies(CaseID, TaxpayerID, TaxYear, BaseAmount, PhasedOutAmount) ->
            ExemptionAmount = PhasedOutAmount
        ; ExemptionAmount = BaseAmount
        )
    ).

% (d)(2) Exemption amount disallowed in case of certain dependents
% This rule means if an INDIVIDUAL can be claimed by another, THEIR OWN personal exemption is $0.
% It affects the ExemptionAmount for that individual if they were filing their own return.
% It's different from s151_count_exemptions for TaxpayerID claiming others.
s151_d_2_disallowed_for_own_exemption(CaseID, PersonID, TaxYear) :-
    s151_is_allowable_as_dependent_to_another(CaseID, PersonID, TaxYear).

s151_is_allowable_as_dependent_to_another(CaseID, PersonID, TaxYear) :-
    fact(CaseID, can_be_claimed_as_dependent_by(PersonID, _AnotherTaxpayerID, TaxYear)).

% (d)(3) Phaseout
s151_d_3_phaseout_applies(CaseID, TaxpayerID, TaxYear, BaseAmount, PhasedOutAmount) :-
    fact(CaseID, adjusted_gross_income(TaxpayerID, TaxYear, AGI)),
    s68_b_applicable_amount(CaseID, TaxpayerID, TaxYear, ThresholdAGI), % Uses S68(b) amounts
    AGI > ThresholdAGI,
    s151_d_3_B_applicable_percentage(CaseID, TaxpayerID, TaxYear, PercentageDecimal), % e.g., 0.22 for 22%
    Reduction is BaseAmount * PercentageDecimal,
    PhasedOutAmount is max(0, BaseAmount - Reduction). % Cannot go below zero

s151_d_3_B_applicable_percentage(CaseID, TaxpayerID, TaxYear, PercentageDecimal) :-
    fact(CaseID, adjusted_gross_income(TaxpayerID, TaxYear, AGI)),
    s68_b_applicable_amount(CaseID, TaxpayerID, TaxYear, ThresholdAGI),
    AGI > ThresholdAGI, % Should be guaranteed if called from phaseout_applies
    ExcessAGI is AGI - ThresholdAGI,
    ( fact(CaseID, filing_status(TaxpayerID, TaxYear, married_filing_separately)) ->
        Divisor = 1250
    ; Divisor = 2500
    ),
    NumIncrements is ceil(ExcessAGI / Divisor),
    RawPercentage is NumIncrements * 2, % 2 percentage points
    CappedPercentage is min(RawPercentage, 100),
    PercentageDecimal is CappedPercentage / 100.0.

% Helper: s151_is_entitled_to_deduction_for_dependent (used by Sec 2 etc.)
% This checks if TaxpayerID can claim DependentID under Sec 151 rules (mainly by being a Sec 152 dependent).
% For 2018-2025, the amount is $0, but "entitlement" might still exist.
s151_is_entitled_to_deduction_for_dependent(CaseID, TaxpayerID, DependentID, TaxYear) :-
    s152_is_dependent(CaseID, TaxpayerID, DependentID, TaxYear). % Core check

% Helper for s151b spouse exemption
s152_is_dependent_of_another_taxpayer(CaseID, PersonID, TaxYear) :-
    fact(CaseID, is_dependent_of_another(PersonID, TaxYear)). % Simplified fact needed from case