:- module(statute_63,
          [ taxable_income/4,
            basic_standard_deduction/4,
            additional_standard_deduction/3
          ]).

/**
 * statute_63.pl
 *
 * This module implements §63, which defines "taxable income". It handles
 * the two main pathways: for individuals who itemize deductions and for
 * those who take the standard deduction.
 *
 * It provides predicates for calculating the standard deduction, including the
 * basic and additional amounts, and applies limitations as specified.
 */

:- use_module(helpers).
:- use_module(knowledge_base).

% The system will provide the 'fact' predicates at runtime.
:- discontiguous fact/1, fact/2, fact/3, fact/4.

% taxable_income(+Taxpayer, +Year, +FilingStatus, -TaxableIncome)
%
% This is the main predicate for this section. It determines whether the taxpayer
% itemizes and calculates taxable income accordingly.
taxable_income(Taxpayer, Year, _FilingStatus, TaxableIncome) :-
    fact(itemizes_deductions(Taxpayer, Year)), !,
    fact(gross_income(Taxpayer, Year, GrossIncome)),
    fact(itemized_deductions_before_limitation(Taxpayer, Year, RawDeductions)),
    fact(adjusted_gross_income(Taxpayer, Year, AGI)),
    % Apply the §68 overall limitation on itemized deductions
    statute_68:allowable_itemized_deductions(Taxpayer, Year, RawDeductions, AGI, FinalItemizedDeductions),
    TaxableIncome is GrossIncome - FinalItemizedDeductions.

taxable_income(Taxpayer, Year, FilingStatus, TaxableIncome) :-
    % Case for individuals who do not itemize (§63(b))
    fact(adjusted_gross_income(Taxpayer, Year, AGI)),
    standard_deduction(Taxpayer, Year, FilingStatus, StdDed),
    % §151 deduction is needed, which in turn might need AGI for phaseout
    statute_151:personal_exemption_deduction(Taxpayer, Year, FilingStatus, AGI, PersEx),
    Unrounded is AGI - StdDed - PersEx,
    TaxableIncome is max(0, Unrounded).

% standard_deduction(+Taxpayer, +Year, +FilingStatus, -Deduction)
%
% Calculates the total standard deduction (§63(c)(1)).
standard_deduction(Taxpayer, Year, FilingStatus, 0) :-
    is_ineligible_for_standard_deduction(Taxpayer, Year, FilingStatus), !.
standard_deduction(Taxpayer, Year, FilingStatus, Deduction) :-
    % Check for dependent limitation on basic deduction (§63(c)(5))
    ( fact(is_dependent_of(Taxpayer, _, Year)) ->
        limited_basic_standard_deduction(Taxpayer, Year, Basic)
    ;
        basic_standard_deduction(Taxpayer, Year, FilingStatus, Basic)
    ),
    additional_standard_deduction(Taxpayer, Year, Additional),
    Deduction is Basic + Additional.

% basic_standard_deduction(+Taxpayer, +Year, +FilingStatus, -Deduction)
%
% Implements §63(c)(2) and the TCJA update in §63(c)(7). Exported for testing.
basic_standard_deduction(_Taxpayer, Year, FilingStatus, Deduction) :-
    helpers:get_year_period(Year, Period),
    map_filing_status_to_kb_key(FilingStatus, KB_Status),
    knowledge_base:standard_deduction_amount(Period, KB_Status, Deduction).

% additional_standard_deduction(+Taxpayer, +Year, -TotalAdditional)
%
% Implements §63(c)(3) by summing the aged/blind amounts from §63(f). Exported for testing.
additional_standard_deduction(Taxpayer, Year, TotalAdditional) :-
    statute_2:filing_status(Taxpayer, Year, FilingStatus),
    get_additional_amount_value(FilingStatus, UnitAmount),
    % Count entitlements for the taxpayer
    ( is_aged_or_blind(Taxpayer, Year, is_aged) -> SelfAged = 1 ; SelfAged = 0 ),
    ( is_aged_or_blind(Taxpayer, Year, is_blind) -> SelfBlind = 1 ; SelfBlind = 0 ),
    SelfCount is SelfAged + SelfBlind,
    % Count entitlements for the spouse, if applicable
    ( fact(spouse_of(Taxpayer, Spouse, Year)),
      statute_151:spouse_exemption_count(Taxpayer, FilingStatus, Year, 1) ->
        ( is_aged_or_blind(Spouse, Year, is_aged) -> SpouseAged = 1 ; SpouseAged = 0 ),
        ( is_aged_or_blind(Spouse, Year, is_blind) -> SpouseBlind = 1 ; SpouseBlind = 0 ),
        SpouseCount is SpouseAged + SpouseBlind
    ; SpouseCount = 0
    ),
    TotalCount is SelfCount + SpouseCount,
    TotalAdditional is TotalCount * UnitAmount.

% ---- Helper Predicates ----

% is_ineligible_for_standard_deduction(+Taxpayer, +Year, +FilingStatus)
%
% Implements the ineligibility rules from §63(c)(6).
is_ineligible_for_standard_deduction(Taxpayer, Year, FilingStatus) :-
    ( FilingStatus == married_filing_separately ; FilingStatus == married_filing_separately ),
    fact(spouse_itemizes_deductions(Taxpayer, Year)), !.
is_ineligible_for_standard_deduction(Taxpayer, Year, _) :-
    fact(nonresident_alien_individual(Taxpayer, Year)).

% limited_basic_standard_deduction(+Taxpayer, +Year, -LimitedDeduction)
%
% Implements the limitation for dependents from §63(c)(5).
limited_basic_standard_deduction(Taxpayer, Year, LimitedDeduction) :-
    fact(earned_income(Taxpayer, Year, EarnedIncome)),
    knowledge_base:basic_standard_deduction_limitation(base, Base),
    knowledge_base:basic_standard_deduction_limitation(earned_income_add, Add),
    IncomeBasedAmount is EarnedIncome + Add,
    LimitedDeduction is max(Base, IncomeBasedAmount).

% is_aged_or_blind(+Person, +Year, -Condition)
%
% Checks if a person is aged (>=65) or blind for the tax year.
is_aged_or_blind(Person, Year, is_aged) :-
    fact(date_of_birth(Person, Y, M, _)),
    helpers:get_age_at_year_end(Y, M, Year, Age),
    Age >= 65.
is_aged_or_blind(Person, Year, is_blind) :-
    fact(is_blind(Person, Year)).

% get_additional_amount_value(+FilingStatus, -Amount)
%
% Implements §63(f)(3) to find the per-item value ($600 or $750).
get_additional_amount_value(Status, Amount) :-
    ( (Status == unmarried ; Status == head_of_household) ->
        knowledge_base:additional_standard_deduction_amount(unmarried_not_surviving_spouse, Amount)
    ;
        knowledge_base:additional_standard_deduction_amount(default, Amount)
    ).

% map_filing_status_to_kb_key(+FilingStatus, -KB_Status)
%
% Maps the filing status atoms to the keys used in knowledge_base.pl.
map_filing_status_to_kb_key(married_filing_jointly, joint_return).
map_filing_status_to_kb_key(surviving_spouse, surviving_spouse).
map_filing_status_to_kb_key(head_of_household, head_of_household).
map_filing_status_to_kb_key(married_filing_separately, other).
map_filing_status_to_kb_key(unmarried, other).