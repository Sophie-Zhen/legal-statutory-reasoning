:- module(section63,
          [ taxable_income/4,                % taxable_income(Taxpayer, CaseID, Year, TaxableIncome)
            standard_deduction/4,            % standard_deduction(Taxpayer, CaseID, Year, Deduction)
            basic_standard_deduction/4,      % basic_standard_deduction(Taxpayer, FilingStatus, Year, Deduction)
            additional_standard_deduction/3, % additional_standard_deduction(Taxpayer, CaseID, Year, Deduction)
            is_eligible_for_standard_deduction/3 % is_eligible_for_standard_deduction(Taxpayer, CaseID, Year)
          ]).

:- use_module(tests, [fact/2]).
:- use_module(helpers, [calculate_age_at_year_end/3]).
:- use_module(knowledge_base, [basic_standard_deduction_amount/3, additional_deduction_aged_blind/3, dependent_deduction_limitation/3]).
:- use_module(section151, [personal_exemption_deduction/4]).
:- use_module(section2, [filing_status/4]).
:- use_module(section68, [limited_itemized_deductions/4]).


% §63(a) & (b) Top-level predicate for taxable income
taxable_income(Taxpayer, CaseID, Year, TaxableIncome) :-
    fact(CaseID, gross_income(Taxpayer, Year, GrossIncome)),
    % Assuming AGI = GrossIncome for these cases, as no above-the-line deductions are given.
    fact(CaseID, adjusted_gross_income(Taxpayer, Year, GrossIncome)),
    (   % Itemizes deductions
        fact(CaseID, elects_to_itemize_deductions(Taxpayer, Year))
    ->  % §63(a) Taxable Income = Gross Income - Itemized Deductions
        limited_itemized_deductions(Taxpayer, CaseID, Year, ItemizedDeductions),
        TaxableIncome is max(0, GrossIncome - ItemizedDeductions)
    ;   % Does not itemize, takes standard deduction
        % §63(b) Taxable Income = AGI - Standard Deduction - Personal Exemptions
        standard_deduction(Taxpayer, CaseID, Year, StdDed),
        personal_exemption_deduction(Taxpayer, CaseID, Year, PersEx),
        TaxableIncome is max(0, GrossIncome - StdDed - PersEx)
    ).

% §63(c)(1) Standard Deduction = Basic + Additional
standard_deduction(Taxpayer, CaseID, Year, Deduction) :-
    is_eligible_for_standard_deduction(Taxpayer, CaseID, Year), !,
    filing_status(Taxpayer, CaseID, Year, Status),
    basic_standard_deduction(Taxpayer, Status, Year, Basic),
    additional_standard_deduction(Taxpayer, CaseID, Year, Additional),
    Deduction is Basic + Additional.
standard_deduction(_, _, _, 0). % Not eligible


% §63(c)(2) Basic Standard Deduction
basic_standard_deduction(Taxpayer, Status, Year, Deduction) :-
    % §63(c)(5) Limitation for dependents
    (   fact(CaseID, is_dependent_of(Taxpayer, _, Year))
    ->  dependent_deduction_limitation(Year, floor, Floor),
        dependent_deduction_limitation(Year, earned_income_add, Add),
        (fact(CaseID, earned_income(Taxpayer, Year, Earned)) -> true ; Earned = 0),
        Limit is max(Floor, Earned + Add),
        basic_standard_deduction_amount(Year, Status, BaseAmount),
        Deduction is min(BaseAmount, Limit)
    ;   % No limitation
        basic_standard_deduction_amount(Year, Status, Deduction)
    ).

% §63(c)(3) & (f) Additional Standard Deduction
additional_standard_deduction(Taxpayer, CaseID, Year, TotalAdditional) :-
    filing_status(Taxpayer, CaseID, Year, Status),
    additional_deduction_aged_blind(Year, Status, AmountPerItem),
    findall(AmountPerItem, is_entitled_to_additional(Taxpayer, CaseID, Year, _Reason), Amounts),
    helpers:sum_list(Amounts, TotalAdditional).

is_entitled_to_additional(Taxpayer, CaseID, Year, aged_self) :-
    % §63(f)(1)(A)
    fact(CaseID, birth_year(Taxpayer, BirthYear)),
    calculate_age_at_year_end(BirthYear, Year, Age),
    Age >= 65.
is_entitled_to_additional(Taxpayer, CaseID, Year, blind_self) :-
    % §63(f)(2)(A)
    fact(CaseID, is_blind(Taxpayer, Year)).
is_entitled_to_additional(Taxpayer, CaseID, Year, aged_spouse) :-
    % §63(f)(1)(B)
    fact(CaseID, spouse(Taxpayer, Spouse)),
    fact(CaseID, birth_year(Spouse, BirthYear)),
    calculate_age_at_year_end(BirthYear, Year, Age),
    Age >= 65,
    % Check if additional exemption for spouse is allowable under 151(b)
    \+ fact(CaseID, files_joint_return(Taxpayer, Spouse, Year)),
    \+ (fact(CaseID, gross_income(Spouse, Year, Inc)), Inc > 0),
    \+ fact(CaseID, is_dependent_of(Spouse, _, Year)).
is_entitled_to_additional(Taxpayer, CaseID, Year, blind_spouse) :-
    % §63(f)(2)(B)
    fact(CaseID, spouse(Taxpayer, Spouse)),
    fact(CaseID, is_blind(Spouse, Year)),
    % Check if additional exemption for spouse is allowable under 151(b)
    \+ fact(CaseID, files_joint_return(Taxpayer, Spouse, Year)),
    \+ (fact(CaseID, gross_income(Spouse, Year, Inc)), Inc > 0),
    \+ fact(CaseID, is_dependent_of(Spouse, _, Year)).


% §63(c)(6) Individuals not eligible for standard deduction
is_eligible_for_standard_deduction(Taxpayer, CaseID, Year) :-
    % (A) Married filing separately and spouse itemizes
    \+ (fact(CaseID, files_separate_return(Taxpayer, Year)),
        fact(CaseID, spouse(Taxpayer, Spouse)),
        fact(CaseID, elects_to_itemize_deductions(Spouse, Year))
       ),
    % (B) Nonresident alien
    \+ fact(CaseID, nonresident_alien(Taxpayer, Year)).
