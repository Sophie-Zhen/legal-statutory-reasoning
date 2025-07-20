:- module(section151,
          [
            s151_total_personal_exemption_deduction/4, % s151_total_personal_exemption_deduction(CaseID, TaxpayerID, TaxYear, TotalExemptionAmount)
            s151_entitled_to_deduction_for_individual/5, % s151_entitled_to_deduction_for_individual(CaseID, TaxpayerID, IndividualID, TaxYear, IsEntitledBool)
            s151_base_exemption_amount_for_year/2 % s151_base_exemption_amount_for_year(TaxYear, BaseAmount) - before phaseout etc.
          ]).
:- use_module(section152, [s152_is_dependent/5]).
:- use_module(section68, [s68_b_applicable_amount/4]). % For phaseout AGI thresholds
:- use_module(helpers, [tcja_active_general/1]).
:- use_module(tests, [fact/2]). % Or pass facts
% s151_entitled_to_deduction_for_individual(CaseID, TaxpayerID, IndividualID, TaxYear, IsEntitledBool)
% Checks if TaxpayerID is entitled to a deduction for IndividualID (self, spouse, or dependent).
% This is used by other sections (like Sec 2) that refer to "entitled to a deduction under section 151".
% Entitlement exists even if TCJA makes the amount $0.
s151_entitled_to_deduction_for_individual(CaseID, TaxpayerID, IndividualID, TaxYear, true) :-
    TaxpayerID == IndividualID, % Entitled for self
    \+ s151_d_2_exemption_disallowed_coz_dependent_of_another(CaseID, TaxpayerID, TaxYear, true),
    !.
s151_entitled_to_deduction_for_individual(CaseID, TaxpayerID, IndividualID, TaxYear, true) :-
    s151_b_spouse_conditions_met(CaseID, TaxpayerID, IndividualID, TaxYear, true), % IndividualID is qualifying spouse
    !.
s151_entitled_to_deduction_for_individual(CaseID, TaxpayerID, IndividualID, TaxYear, true) :-
    s152_is_dependent(CaseID, TaxpayerID, IndividualID, TaxYear, true), % IndividualID is a dependent of TaxpayerID
    !.
s151_entitled_to_deduction_for_individual(_, _, _, _, false).
% s151_total_personal_exemption_deduction(CaseID, TaxpayerID, TaxYear, TotalExemptionAmount)
s151_total_personal_exemption_deduction(CaseID, TaxpayerID, TaxYear, TotalExemptionAmount) :-
    s151_d_5_current_exemption_amount(TaxYear, CurrentBaseExemptionAmount), % This is $0 for 2018-2025, or $2000 (etc.) otherwise
    ( CurrentBaseExemptionAmount =:= 0 ->
        TotalExemptionAmount = 0
    ; % Calculate exemptions if CurrentBaseExemptionAmount > 0 (pre-TCJA logic)
        s151_b_taxpayer_exemption_amount(CaseID, TaxpayerID, TaxYear, CurrentBaseExemptionAmount, TaxpayerExemption),
        s151_b_spouse_exemption_amount(CaseID, TaxpayerID, TaxYear, CurrentBaseExemptionAmount, SpouseExemption),
        s151_c_dependents_total_exemption_amount(CaseID, TaxpayerID, TaxYear, CurrentBaseExemptionAmount, DependentsTotalExemption),
        RawTotalExemptions is TaxpayerExemption + SpouseExemption + DependentsTotalExemption,
        % Apply phaseout if applicable (Sec 151(d)(3))
        s151_d_3_apply_phaseout(CaseID, TaxpayerID, TaxYear, RawTotalExemptions, PhasedOutTotalExemptionAmount),
        TotalExemptionAmount = PhasedOutTotalExemptionAmount
    ).
% s151_b_taxpayer_exemption_amount(CaseID, TaxpayerID, TaxYear, BaseExemptionPerPerson, TaxpayerExemption)
s151_b_taxpayer_exemption_amount(CaseID, TaxpayerID, TaxYear, BaseExemptionPerPerson, TaxpayerExemption) :-
    ( s151_d_2_exemption_disallowed_coz_dependent_of_another(CaseID, TaxpayerID, TaxYear, true) ->
        TaxpayerExemption = 0 % Taxpayer themselves can be claimed by another
    ; TaxpayerExemption = BaseExemptionPerPerson
    ).
% s151_b_spouse_exemption_amount(CaseID, TaxpayerID, TaxYear, BaseExemptionPerPerson, SpouseExemption)
s151_b_spouse_exemption_amount(CaseID, TaxpayerID, TaxYear, BaseExemptionPerPerson, SpouseExemption) :-
    ( fact(CaseID, spouse_of(TaxpayerID, SpouseID)),
      s151_b_spouse_conditions_met(CaseID, TaxpayerID, SpouseID, TaxYear, true) ->
        ( s151_d_2_exemption_disallowed_coz_dependent_of_another(CaseID, SpouseID, TaxYear, true) ->
            SpouseExemption = 0 % Spouse can be claimed by another
        ; SpouseExemption = BaseExemptionPerPerson
        )
    ; SpouseExemption = 0 % No qualifying spouse or conditions not met
    ).
% s151_b_spouse_conditions_met(CaseID, TaxpayerID, SpouseID, TaxYear, ConditionsMetBool)
% Conditions for spouse exemption: joint return NOT made, spouse no gross income, spouse not dependent of another.
s151_b_spouse_conditions_met(CaseID, TaxpayerID, SpouseID, TaxYear, true) :-
    fact(CaseID, spouse_of(TaxpayerID, SpouseID)), % Ensure SpouseID is indeed the spouse
    \+ fact(CaseID, files_joint_return(TaxpayerID, SpouseID, TaxYear)),
    fact(CaseID, gross_income(SpouseID, TaxYear, SpouseGrossIncome)),
    SpouseGrossIncome =:= 0,
s151_is_dependent_of_another_taxpayer(CaseID, SpouseID, TaxYear, TaxpayerID, false),
    !.
s151_b_spouse_conditions_met(_, _, _, _, false).
% s151_is_dependent_of_another_taxpayer(CaseID, IndividualID, TaxYear, CurrentTaxpayerIDToExclude, IsDependentBool)
% Checks if IndividualID is a dependent of any taxpayer OTHER than CurrentTaxpayerIDToExclude.
s151_is_dependent_of_another_taxpayer(CaseID, IndividualID, TaxYear, CurrentTaxpayerIDToExclude, true) :-
    fact(CaseID, person_is_taxpayer(OtherTaxpayerID)),
    OtherTaxpayerID \== CurrentTaxpayerIDToExclude,
    s152_is_dependent(CaseID, OtherTaxpayerID, IndividualID, TaxYear, true),
    !.
s151_is_dependent_of_another_taxpayer(_, _, _, _, false).
% s151_c_dependents_total_exemption_amount(CaseID, TaxpayerID, TaxYear, BaseExemptionPerPerson, DependentsTotalExemption)
s151_c_dependents_total_exemption_amount(CaseID, TaxpayerID, TaxYear, BaseExemptionPerPerson, DependentsTotalExemption) :-
    findall(DependentID,
            (fact(CaseID, potential_dependent_of(TaxpayerID, DependentID)), % Fact linking TP to potential dependents
             s152_is_dependent(CaseID, TaxpayerID, DependentID, TaxYear, true)
            ),
            ListOfDependents),
    length(ListOfDependents, NumberOfDependents),
    DependentsTotalExemption is NumberOfDependents * BaseExemptionPerPerson.
% s151_d_1_base_amount(TaxYear, BaseAmount)
% This is the $2000 amount, pre-TCJA, pre-phaseout.
s151_d_1_base_amount(_TaxYear, 2000). % For simplicity, not inflation adjusted.
% s151_d_5_current_exemption_amount(TaxYear, CurrentExemptionAmount)
% Determines the actual base exemption amount per person for the year, considering TCJA.
s151_d_5_current_exemption_amount(TaxYear, 0) :-
    s151_d_5_special_rules_2018_2025_active(TaxYear, true),
    !.
s151_d_5_current_exemption_amount(TaxYear, BaseAmount) :-
    s151_d_1_base_amount(TaxYear, BaseAmount). % Pre-TCJA or post-TCJA if it reverts
% s151_d_2_exemption_disallowed_coz_dependent_of_another(CaseID, IndividualID, TaxYear, IsDisallowedBool)
% Exemption amount for IndividualID is zero if IndividualID is allowable as a deduction (dependent) to another taxpayer.
s151_d_2_exemption_disallowed_coz_dependent_of_another(CaseID, IndividualID, TaxYear, true) :-
    fact(CaseID, person_is_taxpayer(AnotherTaxpayerID)),
    AnotherTaxpayerID \== IndividualID, % Cannot be dependent of oneself for this rule
    s151_entitled_to_deduction_for_individual(CaseID, AnotherTaxpayerID, IndividualID, TaxYear, true),
    % s152_is_dependent(CaseID, AnotherTaxpayerID, IndividualID, TaxYear, true),
    !.
s151_d_2_exemption_disallowed_coz_dependent_of_another(_, _, _, false).
% s151_d_3_apply_phaseout(CaseID, TaxpayerID, TaxYear, InitialTotalExemption, PhasedOutTotalExemption)
s151_d_3_apply_phaseout(_CaseID, _TaxpayerID, TaxYear, InitialTotalExemption, InitialTotalExemption) :-
    tcja_active_general(TaxYear), % Phaseout not active during TCJA years for PE
    !.
s151_d_3_apply_phaseout(CaseID, TaxpayerID, TaxYear, InitialTotalExemption, PhasedOutTotalExemption) :-
    fact(CaseID, adjusted_gross_income(TaxpayerID, TaxYear, AGI)),
    s68_b_applicable_amount(CaseID, TaxpayerID, TaxYear, ApplicableAmountS68b), % Use Sec 68(b) thresholds
    ( AGI =< ApplicableAmountS68b ->
        PhasedOutTotalExemption = InitialTotalExemption % No phaseout if AGI below threshold
    ;   s151_d_3_B_calculate_applicable_percentage(CaseID, TaxpayerID, TaxYear, AGI, ApplicableAmountS68b, Percentage),
        Reduction is InitialTotalExemption * Percentage,
        PhasedOutAmount is InitialTotalExemption - Reduction,
        ( PhasedOutAmount < 0 -> PhasedOutTotalExemption = 0 ; PhasedOutTotalExemption = PhasedOutAmount )
    ).
% s151_d_3_B_calculate_applicable_percentage(CaseID, TaxpayerID, TaxYear, AGI, ThresholdAGI, Percentage)
s151_d_3_B_calculate_applicable_percentage(CaseID, TaxpayerID, TaxYear, AGI, ThresholdAGI, ApplicablePercentage) :-
    ExcessAGI is AGI - ThresholdAGI,
    ( fact(CaseID, filing_status(TaxpayerID, TaxYear, married_filing_separately)) ->
        IncrementAmount = 1250
    ; IncrementAmount = 2500
    ),
    NumberOfIncrements_Float is ExcessAGI / IncrementAmount,
    NumberOfIncrements is ceiling(NumberOfIncrements_Float), % "or fraction thereof"
    PercentagePoints is NumberOfIncrements * 2,
    CalculatedPercentage is PercentagePoints / 100,
    ( CalculatedPercentage > 1.0 -> ApplicablePercentage = 1.0 % Cannot exceed 100%
    ; ApplicablePercentage = CalculatedPercentage
    ).
% s151_d_5_special_rules_2018_2025_active(TaxYear, IsActiveBool)
s151_d_5_special_rules_2018_2025_active(TaxYear, true) :-
    tcja_active_general(TaxYear), % Uses the general TCJA period
    !.
s151_d_5_special_rules_2018_2025_active(_, false).
% Exported for convenience if other modules need the base $2000 (or future inflation adjusted) value directly
s151_base_exemption_amount_for_year(TaxYear, BaseAmount) :-
    s151_d_1_base_amount(TaxYear, BaseAmount).