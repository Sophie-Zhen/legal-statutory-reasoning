:- module(section68,
          [
            s68_calculate_allowable_itemized_deductions/5, % s68_calculate_allowable_itemized_deductions(CaseID, TaxpayerID, TaxYear, OtherwiseAllowableDeductions, FinalDeductions)
            s68_b_applicable_amount/4 % s68_b_applicable_amount(CaseID, TaxpayerID, TaxYear, ApplicableAmount) - Exported for Sec 151
          ]).
:- use_module(section2, [s2_a_is_surviving_spouse/4, s2_b_is_head_of_household/4]).
:- use_module(section7703, [s7703_determination_of_marital_status/4]).
:- use_module(helpers, [tcja_active_general/1]).
:- use_module(tests, [fact/2]). % Or pass facts
% s68_calculate_allowable_itemized_deductions(CaseID, TaxpayerID, TaxYear, OtherwiseAllowableDeductions, FinalDeductions)
s68_calculate_allowable_itemized_deductions(_CaseID, _TaxpayerID, TaxYear, OtherwiseAllowableDeductions, OtherwiseAllowableDeductions) :-
    s68_f_section_not_to_apply(TaxYear, true), % TCJA suspends Sec 68
    !.
s68_calculate_allowable_itemized_deductions(CaseID, TaxpayerID, TaxYear, OtherwiseAllowableDeductions, FinalDeductions) :-
    fact(CaseID, adjusted_gross_income(TaxpayerID, TaxYear, AGI)),
    s68_b_applicable_amount(CaseID, TaxpayerID, TaxYear, ApplicableAmount),
    ( AGI =< ApplicableAmount ->
        FinalDeductions = OtherwiseAllowableDeductions % No reduction if AGI below threshold
    ; % AGI exceeds threshold, calculate reduction
        s68_a_calculate_reduction(AGI, ApplicableAmount, OtherwiseAllowableDeductions, ReductionAmount),
        CalcFinalDeductions is OtherwiseAllowableDeductions - ReductionAmount,
        ( CalcFinalDeductions < 0 -> FinalDeductions = 0 ; FinalDeductions = CalcFinalDeductions )
    ).
% s68_a_calculate_reduction(AGI, ApplicableAmount, OtherwiseAllowableDeductions, ReductionAmount)
s68_a_calculate_reduction(AGI, ApplicableAmount, OtherwiseAllowableDeductions, ReductionAmount) :-
    ExcessAGI is AGI - ApplicableAmount,
    Reduction1 is 0.03 * ExcessAGI, % 3 percent of excess AGI
    Reduction2 is 0.80 * OtherwiseAllowableDeductions, % 80 percent of itemized deductions
    ReductionAmount is min(Reduction1, Reduction2). % Lesser of the two
% s68_b_applicable_amount(CaseID, TaxpayerID, TaxYear, ApplicableAmount)
s68_b_applicable_amount(CaseID, TaxpayerID, TaxYear, 300000) :- % (A) Joint return or surviving spouse
    ( fact(CaseID, files_joint_return(TaxpayerID, _SpouseID, TaxYear))
    ; s2_a_is_surviving_spouse(CaseID, TaxpayerID, TaxYear, true)
    ), !.
s68_b_applicable_amount(CaseID, TaxpayerID, TaxYear, 275000) :- % (B) Head of household
    s2_b_is_head_of_household(CaseID, TaxpayerID, TaxYear, true), % Check HoH status
    !.
s68_b_applicable_amount(CaseID, TaxpayerID, TaxYear, 150000) :- % (D) Married filing separately (1/2 of A)
    s7703_determination_of_marital_status(CaseID, TaxpayerID, TaxYear, MaritalStatus),
    MaritalStatus == married, % Must be married
    fact(CaseID, files_separate_return(TaxpayerID, TaxYear)), % And files separate
    !.
s68_b_applicable_amount(_CaseID, _TaxpayerID, _TaxYear, 250000). % (C) Default: single, or other non-married not HoH/SS.
    % This is for individual not married AND not SS AND not HoH.
    % If s7703_determination_of_marital_status says 'not_married', and they are not SS or HoH.
% s68_f_section_not_to_apply(TaxYear, NotApplicableBool)
% This section shall not apply to any taxable year beginning after Dec 31, 2017, and before Jan 1, 2026.
s68_f_section_not_to_apply(TaxYear, true) :-
    tcja_active_general(TaxYear),
    !.
s68_f_section_not_to_apply(_, false).