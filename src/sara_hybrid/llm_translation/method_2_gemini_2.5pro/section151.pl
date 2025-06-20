:- module(section151,
          [ s151_total_deduction_personal_exemptions/4, % s151_total_deduction_personal_exemptions(CaseID, TaxpayerID, TaxYear, TotalDeduction)
            s151_is_entitled_to_deduction_for_person/4,   % s151_is_entitled_to_deduction_for_person(CaseID, TaxpayerID, ForWhomID, TaxYear)
            s151_d_exemption_amount/4,                    % s151_d_exemption_amount(CaseID, TaxpayerID, ForWhomID, TaxYear, Amount)
            s151_d_3_B_applicable_percentage/5,           % s151_d_3_B_applicable_percentage(CaseID, TaxpayerID, TaxYear, AGI, ApplicablePercentage)
            s151_b_taxpayer_and_spouse_exemption_conditions_met/5 % s151_b_taxpayer_and_spouse_exemption_conditions_met(CaseID, TaxpayerID, SpouseID, TaxYear, IsMetBool)
          ]).

:- use_module(helpers, [tcja_personal_exemption_zero_active/1, ceil_dollars/2]).
:- use_module(section152, [s152_is_dependent/4]).
:- use_module(section68, [s68_b_applicable_amount/4]). % For phaseout threshold

:- dynamic fact/2.

s151_total_deduction_personal_exemptions(CaseID, TaxpayerID, TaxYear, TotalDeduction) :-
    % Exemption for taxpayer
    s151_d_exemption_amount(CaseID, TaxpayerID, TaxpayerID, TaxYear, TaxpayerExemptionAmount),
    % Exemption for spouse (if applicable)
    (   fact(CaseID, spouse_of(TaxpayerID, SpouseID)),
        s151_b_taxpayer_and_spouse_exemption_conditions_met(CaseID, TaxpayerID, SpouseID, TaxYear, true)
    ->  s151_d_exemption_amount(CaseID, TaxpayerID, SpouseID, TaxYear, SpouseExemptionAmount)
    ;   SpouseExemptionAmount = 0
    ),
    % Exemptions for dependents
    findall(DependentExemptionAmount,
            (fact(CaseID, potential_dependent_of(DependentID, TaxpayerID)), % Assumes a fact identifies potential dependents
             s152_is_dependent(CaseID, TaxpayerID, DependentID, TaxYear),
             s151_d_exemption_amount(CaseID, TaxpayerID, DependentID, TaxYear, DependentExemptionAmount)
            ),
            DependentExemptionAmountsList),
    sum_list([TaxpayerExemptionAmount, SpouseExemptionAmount | DependentExemptionAmountsList], TotalDeduction).

% Helper: s151_is_entitled_to_deduction_for_person - this is a general check of eligibility, not amount
s151_is_entitled_to_deduction_for_person(CaseID, TaxpayerID, TaxpayerID, TaxYear) :- % For self
    \+ s151_d_2_exemption_disallowed_for_dependent(CaseID, TaxpayerID, TaxYear).
s151_is_entitled_to_deduction_for_person(CaseID, TaxpayerID, SpouseID, TaxYear) :- % For spouse
    fact(CaseID, spouse_of(TaxpayerID, SpouseID)),
    s151_b_taxpayer_and_spouse_exemption_conditions_met(CaseID, TaxpayerID, SpouseID, TaxYear, true).
s151_is_entitled_to_deduction_for_person(CaseID, TaxpayerID, DependentID, TaxYear) :- % For dependent
    s152_is_dependent(CaseID, TaxpayerID, DependentID, TaxYear).

% §151(b) Taxpayer and spouse
s151_b_taxpayer_and_spouse_exemption_conditions_met(CaseID, TaxpayerID, SpouseID, TaxYear, true) :-
    \+ fact(CaseID, files_joint_return(TaxpayerID, SpouseID, TaxYear)),
    \+ (fact(CaseID, gross_income(SpouseID, TaxYear, SpouseGI)), SpouseGI > 0),
    \+ fact(CaseID, is_dependent_of_another_taxpayer(SpouseID, TaxYear, _OtherTaxpayerID)).
s151_b_taxpayer_and_spouse_exemption_conditions_met(_, _, _, _, false).


% §151(d) Exemption amount
s151_d_exemption_amount(CaseID, _TaxpayerFilingReturn, ForWhomID, TaxYear, 0) :- % §151(d)(5)
    tcja_personal_exemption_zero_active(TaxYear).
s151_d_exemption_amount(CaseID, _TaxpayerFilingReturn, ForWhomID, TaxYear, 0) :- % §151(d)(2)
    \+ tcja_personal_exemption_zero_active(TaxYear),
    s151_d_2_exemption_disallowed_for_dependent(CaseID, ForWhomID, TaxYear).
s151_d_exemption_amount(CaseID, TaxpayerFilingReturn, ForWhomID, TaxYear, ActualAmount) :- % §151(d)(1) & (d)(3)
    \+ tcja_personal_exemption_zero_active(TaxYear),
    \+ s151_d_2_exemption_disallowed_for_dependent(CaseID, ForWhomID, TaxYear),
    BaseAmount = 2000,
    (   fact(CaseID, adjusted_gross_income(TaxpayerFilingReturn, TaxYear, AGI)), % AGI of the filer
        s68_b_applicable_amount(CaseID, TaxpayerFilingReturn, TaxYear, ThresholdAGI),
        AGI > ThresholdAGI
    ->  s151_d_3_B_applicable_percentage(CaseID, TaxpayerFilingReturn, TaxYear, AGI, AppPercentage),
        Reduction is BaseAmount * (AppPercentage / 100),
        PhasedOutAmount is BaseAmount - Reduction,
        ActualAmount is max(0, PhasedOutAmount)
    ;   ActualAmount = BaseAmount
    ).

% §151(d)(2) Exemption amount disallowed in case of certain dependents
s151_d_2_exemption_disallowed_for_dependent(CaseID, IndividualID, TaxYear) :-
    fact(CaseID, is_allowable_as_section151_deduction_to_another(IndividualID, TaxYear, _AnotherTaxpayerID)).

% §151(d)(3)(B) Applicable percentage
s151_d_3_B_applicable_percentage(CaseID, TaxpayerID, TaxYear, AGI, ApplicablePercentage) :-
    s68_b_applicable_amount(CaseID, TaxpayerID, TaxYear, ThresholdAGI),
    ExcessAGI is AGI - ThresholdAGI,
    ( fact(CaseID, filing_status(TaxpayerID, TaxYear, married_filing_separately)) -> Divisor = 1250 ; Divisor = 2500 ),
    NumIncrementsFloat is ExcessAGI / Divisor,
    ceil_dollars(NumIncrementsFloat, NumIncrements), % each $2500 (or fraction thereof)
    RawPercentage is NumIncrements * 2,
    ApplicablePercentage is min(RawPercentage, 100).