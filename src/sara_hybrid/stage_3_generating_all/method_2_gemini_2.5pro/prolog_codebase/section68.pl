:- module(section68,
    [
        limitation_on_itemized_deductions/5,
        applicable_amount/4
    ]).

:- use_module(helpers, [s68_suspended/1]).
:- use_module(knowledge_base, [
    itemized_deduction_phaseout_threshold/3,
    itemized_deduction_phaseout_percentage/1,
    itemized_deduction_phaseout_max_reduction/1
    ]).
:- use_module(section2, [is_surviving_spouse/3, is_head_of_household/3]).
:- use_module(section7703, [is_married/4]).

:- multifile fact/2.

limitation_on_itemized_deductions(_CaseID, _Taxpayer, Year, InitialDeductions, InitialDeductions) :-
    s68_suspended(Year), !.
limitation_on_itemized_deductions(CaseID, Taxpayer, Year, InitialDeductions, FinalDeductions) :-
    fact(CaseID, adjusted_gross_income(Taxpayer, Year, AGI)),
    applicable_amount(CaseID, Taxpayer, Year, ApplicableAmount),
    AGI > ApplicableAmount,
    !,
    ExcessAGI is AGI - ApplicableAmount,
    itemized_deduction_phaseout_percentage(Percentage),
    Reduction1 is ExcessAGI * Percentage,
    itemized_deduction_phaseout_max_reduction(MaxReductionPercent),
    Reduction2 is InitialDeductions * MaxReductionPercent,
    Reduction is min(Reduction1, Reduction2),
    FinalDeductions is InitialDeductions - Reduction.
limitation_on_itemized_deductions(_CaseID, _Taxpayer, _Year, InitialDeductions, InitialDeductions).

applicable_amount(CaseID, Taxpayer, Year, Threshold) :-
    determine_filing_status_for_68(CaseID, Taxpayer, Year, FilingStatus),
    itemized_deduction_phaseout_threshold(Year, FilingStatus, Threshold), !.
applicable_amount(_CaseID, _Taxpayer, Year, Threshold) :-
    itemized_deduction_phaseout_threshold(Year, unmarried, Threshold).

determine_filing_status_for_68(CaseID, Taxpayer, Year, FilingStatus) :-
    (   is_surviving_spouse(CaseID, Taxpayer, Year) -> FilingStatus = surviving_spouse
    ;   is_head_of_household(CaseID, Taxpayer, Year) -> FilingStatus = head_of_household
    ;   is_married(CaseID, Taxpayer, Year, married)
    ->  ( fact(CaseID, files_joint_return(Taxpayer, _, Year)) -> FilingStatus = married_filing_jointly
        ;   FilingStatus = married_filing_separately
        )
    ;   FilingStatus = unmarried
    ).
