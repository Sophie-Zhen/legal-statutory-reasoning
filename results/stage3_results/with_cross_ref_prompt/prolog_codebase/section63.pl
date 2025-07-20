:- module(section63,
    [
        taxable_income/4,
        standard_deduction/4,
        basic_standard_deduction/5,
        additional_standard_deduction/5
    ]).

:- use_module(knowledge_base, [standard_deduction_basic/3, standard_deduction_dependent_limitation/3, standard_deduction_additional_amount/3]).
:- use_module(helpers, [get_age_at_year_end/3]).
:- use_module(section151, [personal_exemption_deduction/4]).
:- use_module(section2, [is_surviving_spouse/3, is_head_of_household/3]).
:- use_module(section7703, [is_married/4]).
:- use_module(section68, [limitation_on_itemized_deductions/5]).

:- multifile fact/2.

taxable_income(CaseID, Taxpayer, Year, TaxableIncome) :-
    fact(CaseID, itemized_deductions(Taxpayer, Year, RawItemizedDeductions)),
    !,
    (fact(CaseID, gross_income(Taxpayer, Year, GrossIncome)); GrossIncome = 0),
    (fact(CaseID, adjusted_gross_income(Taxpayer, Year, AGI)) -> true ; AGI = GrossIncome),
    limitation_on_itemized_deductions(CaseID, Taxpayer, Year, RawItemizedDeductions, AllowedItemizedDeductions),
    personal_exemption_deduction(CaseID, Taxpayer, Year, PersonalExemptionDed),
    TaxableIncomeUnadjusted is AGI - AllowedItemizedDeductions - PersonalExemptionDed,
    TaxableIncome is max(0, TaxableIncomeUnadjusted).
taxable_income(CaseID, Taxpayer, Year, TaxableIncome) :-
    \+ fact(CaseID, itemized_deductions(Taxpayer, Year, _)),
    (fact(CaseID, gross_income(Taxpayer, Year, GrossIncome)); GrossIncome = 0),
    (fact(CaseID, adjusted_gross_income(Taxpayer, Year, AGI)) -> true ; AGI = GrossIncome),
    standard_deduction(CaseID, Taxpayer, Year, StandardDed),
    personal_exemption_deduction(CaseID, Taxpayer, Year, PersonalExemptionDed),
    TaxableIncomeUnadjusted is AGI - StandardDed - PersonalExemptionDed,
    TaxableIncome is max(0, TaxableIncomeUnadjusted).

standard_deduction(CaseID, Taxpayer, Year, 0) :-
    is_ineligible_for_standard_deduction(CaseID, Taxpayer, Year), !.
standard_deduction(CaseID, Taxpayer, Year, Deduction) :-
    determine_filing_status_for_63(CaseID, Taxpayer, Year, FilingStatus),
    basic_standard_deduction(CaseID, Taxpayer, FilingStatus, Year, BasicDed),
    additional_standard_deduction(CaseID, Taxpayer, FilingStatus, Year, AdditionalDed),
    Deduction is BasicDed + AdditionalDed.

basic_standard_deduction(CaseID, Taxpayer, FilingStatus, Year, BasicDed) :-
    fact(CaseID, is_dependent_of(Taxpayer, _OtherTaxpayer, Year)),
    !,
    standard_deduction_dependent_limitation(Year, Floor, Base),
    ( fact(CaseID, earned_income(Taxpayer, Year, EarnedIncome)) -> true ; EarnedIncome = 0 ),
    LimitedDed is EarnedIncome + Base,
    UncappedDed is max(Floor, LimitedDed),
    standard_deduction_basic(Year, FilingStatus, RegularDed),
    BasicDed is min(UncappedDed, RegularDed).
basic_standard_deduction(_CaseID, _Taxpayer, FilingStatus, Year, BasicDed) :-
    standard_deduction_basic(Year, FilingStatus, BasicDed).

additional_standard_deduction(CaseID, Taxpayer, FilingStatus, Year, TotalAdditional) :-
    additional_amount_for_taxpayer(CaseID, Taxpayer, FilingStatus, Year, TaxpayerAmount),
    additional_amount_for_spouse(CaseID, Taxpayer, FilingStatus, Year, SpouseAmount),
    TotalAdditional is TaxpayerAmount + SpouseAmount.

is_ineligible_for_standard_deduction(CaseID, Taxpayer, Year) :-
    is_married(CaseID, Taxpayer, Year, married),
    fact(CaseID, files_separate_return(Taxpayer, Year)),
    (fact(CaseID, married(Taxpayer, Spouse, _)); fact(CaseID, married(Spouse, Taxpayer, _))),
    fact(CaseID, itemized_deductions(Spouse, Year, _)).
is_ineligible_for_standard_deduction(CaseID, Taxpayer, Year) :-
    fact(CaseID, is_nonresident_alien(Taxpayer, Year)).

additional_amount_for_taxpayer(CaseID, Taxpayer, FilingStatus, Year, Amount) :-
    count_taxpayer_conditions(CaseID, Taxpayer, Year, Count),
    standard_deduction_additional_amount(Year, FilingStatus, PerConditionAmount),
    Amount is Count * PerConditionAmount.

additional_amount_for_spouse(CaseID, Taxpayer, FilingStatus, Year, Amount) :-
    (fact(CaseID, married(Taxpayer, Spouse, _)); fact(CaseID, married(Spouse, Taxpayer, _))),
    is_entitled_to_deduction_for_spouse_151b(CaseID, Taxpayer, Spouse, Year),
    count_taxpayer_conditions(CaseID, Spouse, Year, Count),
    standard_deduction_additional_amount(Year, FilingStatus, PerConditionAmount),
    Amount is Count * PerConditionAmount, !.
additional_amount_for_spouse(_, _, _, _, 0).

is_entitled_to_deduction_for_spouse_151b(CaseID, Taxpayer, Spouse, Year) :-
    fact(CaseID, files_separate_return(Taxpayer, Year)),
    \+ (fact(CaseID, gross_income(Spouse, Year, Inc)), Inc > 0),
    \+ fact(CaseID, is_dependent_of(Spouse, _, Year)).
is_entitled_to_deduction_for_spouse_151b(CaseID, Taxpayer, _, Year) :-
    fact(CaseID, files_joint_return(Taxpayer, _, Year)).

count_taxpayer_conditions(CaseID, Person, Year, Count) :-
    ( taxpayer_is_aged(CaseID, Person, Year) -> C1 = 1 ; C1 = 0 ),
    ( taxpayer_is_blind(CaseID, Person, Year) -> C2 = 1 ; C2 = 0 ),
    Count is C1 + C2.

taxpayer_is_aged(CaseID, Person, Year) :-
    fact(CaseID, date_of_birth(Person, DOB)),
    get_age_at_year_end(DOB, Year, Age),
    Age >= 65.
taxpayer_is_blind(CaseID, Person, Year) :-
    fact(CaseID, is_blind(Person, Year)).

determine_filing_status_for_63(CaseID, Taxpayer, Year, FilingStatus) :-
    (   is_surviving_spouse(CaseID, Taxpayer, Year) -> FilingStatus = surviving_spouse
    ;   is_head_of_household(CaseID, Taxpayer, Year) -> FilingStatus = head_of_household
    ;   is_married(CaseID, Taxpayer, Year, married)
    ->  ( fact(CaseID, files_joint_return(Taxpayer, _, Year)) -> FilingStatus = married_filing_jointly
        ;   FilingStatus = married_filing_separately
        )
    ;   FilingStatus = unmarried
    ).
