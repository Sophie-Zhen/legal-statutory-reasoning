:- module(section63,
          [ taxable_income/4,
            standard_deduction/4,
            basic_standard_deduction/4,
            additional_standard_deduction/4,
            is_eligible_for_standard_deduction/3
          ]).

:- use_module(knowledge_base, [standard_deduction_basic/3, standard_deduction_dependent_floor/2, standard_deduction_dependent_earned_income_add/2, additional_std_deduction_amount/4]).
:- use_module(section151, [total_personal_exemption_deduction/4, is_entitled_to_exemption_deduction/4]).
:- use_module(section2, [filing_status/4, is_surviving_spouse/3]).
:- use_module(section68, [itemized_deduction_limitation/5]).
:- use_module(section7703, [is_married/3]).
:- use_module(helpers, [get_age_at_year_end/3, max_list_public/2]).

:- multifile fact/2.

/*
    §63. Taxable income defined
*/

% taxable_income(CaseID, Taxpayer, Year, TaxableIncome)
taxable_income(CaseID, Taxpayer, Year, TaxableIncome) :-
    % §63(b) Individual who does not itemize deductions.
    \+ fact(CaseID, itemizes_deductions(Taxpayer, Year)), !,
    fact(CaseID, adjusted_gross_income(Taxpayer, Year, AGI)),
    standard_deduction(CaseID, Taxpayer, Year, SD),
    total_personal_exemption_deduction(CaseID, Taxpayer, Year, PED),
    TaxableIncome is max(0, AGI - SD - PED).
taxable_income(CaseID, Taxpayer, Year, TaxableIncome) :-
    % §63(a) Individual who itemizes deductions.
    fact(CaseID, itemizes_deductions(Taxpayer, Year)),
    fact(CaseID, gross_income(Taxpayer, Year, GrossIncome)),
    findall(D, fact(CaseID, itemized_deduction(Taxpayer, Year, D)), Deductions),
    sum_list(Deductions, InitialItemizedDeductions),
    itemized_deduction_limitation(CaseID, Taxpayer, Year, InitialItemizedDeductions, FinalItemizedDeductions),
    TaxableIncome is max(0, GrossIncome - FinalItemizedDeductions).

% standard_deduction(CaseID, Taxpayer, Year, SD)
% §63(c)(1) Standard deduction = basic + additional.
standard_deduction(CaseID, Taxpayer, Year, SD) :-
    is_eligible_for_standard_deduction(CaseID, Taxpayer, Year), !,
    basic_standard_deduction(CaseID, Taxpayer, Year, BasicSD),
    additional_standard_deduction(CaseID, Taxpayer, Year, AdditionalSD),
    SD is BasicSD + AdditionalSD.
standard_deduction(_CaseID, _Taxpayer, _Year, 0). % Ineligible.

% is_eligible_for_standard_deduction(CaseID, Taxpayer, Year)
% §63(c)(6) Certain individuals not eligible.
is_eligible_for_standard_deduction(CaseID, Taxpayer, Year) :-
    \+ fact(CaseID, is_nonresident_alien(Taxpayer, Year)),
    \+ ( fact(CaseID, married(Taxpayer, Spouse, _)),
         fact(CaseID, files_separate_return(Taxpayer, Year)),
         fact(CaseID, itemizes_deductions(Spouse, Year))
       ).
% Note: a,b,d are checked, but (d) for estates/trusts is not relevant to individuals.

% basic_standard_deduction(CaseID, Taxpayer, Year, BasicSD)
% §63(c)(2) Basic standard deduction.
basic_standard_deduction(CaseID, Taxpayer, Year, BasicSD) :-
    % §63(c)(5) Limitation for dependents.
    fact(CaseID, claimed_as_dependent_by(Taxpayer, _Other, Year)), !,
    standard_deduction_dependent_floor(Year, Floor),
    standard_deduction_dependent_earned_income_add(Year, AddAmount),
    findall(I, fact(CaseID, earned_income(Taxpayer, Year, I)), Incomes),
    sum_list(Incomes, TotalEarnedIncome),
    max_list_public([Floor, TotalEarnedIncome + AddAmount], LimitedSD),
    filing_status(CaseID, Taxpayer, Year, FilingStatus),
    standard_deduction_basic(Year, FilingStatus, FullSD),
    BasicSD is min(LimitedSD, FullSD).
basic_standard_deduction(CaseID, Taxpayer, Year, BasicSD) :-
    % Standard case.
    \+ fact(CaseID, claimed_as_dependent_by(Taxpayer, _Other, Year)),
    filing_status(CaseID, Taxpayer, Year, FilingStatus),
    ( FilingStatus = joint, fact(CaseID, files_joint_return(_,_,Year)) ->
        standard_deduction_basic(Year, joint, Bsd1),
        (is_surviving_spouse(CaseID, Taxpayer, Year) ->
            standard_deduction_basic(Year, joint, Bsd2), % Same as joint
            BasicSD is max(Bsd1, Bsd2)
        ; BasicSD = Bsd1)
    ; filing_status(CaseID, Taxpayer, Year, FS),
      standard_deduction_basic(Year, FS, BasicSD)
    ).

% additional_standard_deduction(CaseID, Taxpayer, Year, AdditionalSD)
% §63(c)(3) Additional standard deduction for aged and blind.
additional_standard_deduction(CaseID, Taxpayer, Year, TotalAdditionalSD) :-
    findall(Amount, (
        % §63(f)(1)(A) Taxpayer aged
        is_aged(CaseID, Taxpayer, Year),
        get_additional_amount_for(CaseID, Taxpayer, Year, Amount)
    ;
        % §63(f)(2)(A) Taxpayer blind
        is_blind(CaseID, Taxpayer, Year),
        get_additional_amount_for(CaseID, Taxpayer, Year, Amount)
    ;
        % §63(f)(1)(B) Spouse aged
        fact(CaseID, spouse_of(Taxpayer, Spouse)),
        is_aged(CaseID, Spouse, Year),
        is_entitled_to_exemption_deduction(CaseID, Taxpayer, Spouse, Year, _),
        get_additional_amount_for(CaseID, Taxpayer, Year, Amount)
    ;
        % §63(f)(2)(B) Spouse blind
        fact(CaseID, spouse_of(Taxpayer, Spouse)),
        is_blind(CaseID, Spouse, Year),
        is_entitled_to_exemption_deduction(CaseID, Taxpayer, Spouse, Year, _),
        get_additional_amount_for(CaseID, Taxpayer, Year, Amount)
    ), Amounts),
    sum_list(Amounts, TotalAdditionalSD).

% is_aged(CaseID, Person, Year)
is_aged(CaseID, Person, Year) :-
    fact(CaseID, date_of_birth(Person, DOB)),
    get_age_at_year_end(DOB, Year, Age),
    Age >= 65.

% is_blind(CaseID, Person, Year)
is_blind(CaseID, Person, Year) :-
    fact(CaseID, is_blind(Person, Year)).

% get_additional_amount_for(CaseID, Taxpayer, Year, Amount)
% §63(f)(3) Higher amount for certain unmarried individuals.
get_additional_amount_for(CaseID, Taxpayer, Year, Amount) :-
    \+ is_married(CaseID, Taxpayer, Year),
    \+ is_surviving_spouse(CaseID, Taxpayer, Year), !,
    additional_std_deduction_amount(Year, unmarried, _, Amount).
get_additional_amount_for(_CaseID, _Taxpayer, Year, Amount) :-
    additional_std_deduction_amount(Year, married, _, Amount).
