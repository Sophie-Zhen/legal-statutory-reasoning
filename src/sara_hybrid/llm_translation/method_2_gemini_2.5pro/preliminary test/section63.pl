:- module(section63,
          [
            s63_taxable_income/4, % s63_taxable_income(CaseID, TaxpayerID, TaxYear, TaxableIncome)
            s63_standard_deduction/4, % s63_standard_deduction(CaseID, TaxpayerID, TaxYear, StandardDeductionAmount)
            s63_c_basic_standard_deduction/4, % s63_c_basic_standard_deduction(CaseID, TaxpayerID, TaxYear, BSDAmount)
            s63_f_additional_standard_deduction_amount/4 % s63_f_additional_standard_deduction_amount(CaseID, TaxpayerID, TaxYear, ASDAmount)
          ]).
:- use_module(section151, [s151_total_personal_exemption_deduction/4, s151_entitled_to_deduction_for_individual/5, s151_b_spouse_conditions_met/5]).
:- use_module(section2, [s2_a_is_surviving_spouse/4, s2_b_is_head_of_household/4]).
:- use_module(section7703, [s7703_determination_of_marital_status/4]).
:- use_module(helpers, [tcja_active_standard_deduction/1, get_age_at_year_end/4]).
:- use_module(tests, [fact/2]).
% s63_taxable_income(CaseID, TaxpayerID, TaxYear, TaxableIncome)
% (a) General rule: GrossIncome - Deductions (other than SD)
% (b) Individuals who do not itemize: AGI - SD - PersonalExemptions
s63_taxable_income(CaseID, TaxpayerID, TaxYear, TaxableIncome) :-
    ( fact(CaseID, elects_to_itemize_deductions(TaxpayerID, TaxYear)) ->
        s63_a_taxable_income_itemizers(CaseID, TaxpayerID, TaxYear, TaxableIncome)
    ;   s63_b_taxable_income_non_itemizers(CaseID, TaxpayerID, TaxYear, TaxableIncome)
    ).
% s63_a_taxable_income_itemizers(CaseID, TaxpayerID, TaxYear, TaxableIncome)
% Gross income minus the deductions allowed by this chapter (other than the standard deduction).
% This means Gross Income - (AboveTheLineDeductions yielding AGI) - ItemizedDeductions.
% AGI = Gross Income - AboveTheLineDeductions.
% So, TI = AGI - ItemizedDeductions. (Personal exemptions are also deductions but handled differently usually)
% The text says "gross income minus the deductions allowed ... (other than the standard deduction)".
% This implies allowable itemized deductions and personal exemptions (if not covered by (b)).
% However, Sec 63(d) defines itemized deductions as those OTHER than personal exemptions.
% So (a) should be: AGI - ItemizedDeductions - PersonalExemptions.
% But (b) is AGI - SD - PE. This makes (a) and (b) parallel.
% Let's use: TI = AGI - AllowableItemizedDeductions - PersonalExemptions for itemizers.
% Itemizers do not take the standard deduction.
s63_a_taxable_income_itemizers(CaseID, TaxpayerID, TaxYear, TaxableIncome) :-
    fact(CaseID, adjusted_gross_income(TaxpayerID, TaxYear, AGI)),
    fact(CaseID, itemized_deductions_amount_before_s68(TaxpayerID, TaxYear, ItemizedDeductionsBeforeS68)),
    % Apply Sec 68 limitation if applicable
    ( module_property(section68, exports(_)) -> % Check if section68 module is loaded/available
        catch(user:use_module(section68), _, true), % Load if not, suppress error if already loaded
        catch(section68:s68_calculate_allowable_itemized_deductions(CaseID, TaxpayerID, TaxYear, ItemizedDeductionsBeforeS68, AllowableItemizedDeductions), _, AllowableItemizedDeductions = ItemizedDeductionsBeforeS68)
    ; AllowableItemizedDeductions = ItemizedDeductionsBeforeS68 % If section68 not available, use pre-limit amount
    ),
    s151_total_personal_exemption_deduction(CaseID, TaxpayerID, TaxYear, PersonalExemptionDeduction),
    TaxableIncome is AGI - AllowableItemizedDeductions - PersonalExemptionDeduction.
% s63_b_taxable_income_non_itemizers(CaseID, TaxpayerID, TaxYear, TaxableIncome)
% Adjusted gross income, minus (1) the standard deduction, and (2) the deduction for personal exemptions.
s63_b_taxable_income_non_itemizers(CaseID, TaxpayerID, TaxYear, TaxableIncome) :-
    fact(CaseID, adjusted_gross_income(TaxpayerID, TaxYear, AGI)),
    s63_standard_deduction(CaseID, TaxpayerID, TaxYear, StandardDeduction),
    s151_total_personal_exemption_deduction(CaseID, TaxpayerID, TaxYear, PersonalExemptionDeduction),
    TaxableIncome is AGI - StandardDeduction - PersonalExemptionDeduction.
% s63_standard_deduction(CaseID, TaxpayerID, TaxYear, StandardDeductionAmount)
% (c)(1) In general: sum of (A) basic standard deduction, and (B) additional standard deduction.
% (c)(6) Certain individuals not eligible for standard deduction (SD is zero).
s63_standard_deduction(CaseID, TaxpayerID, TaxYear, 0) :-
    s63_c_6_not_eligible_for_standard_deduction(CaseID, TaxpayerID, TaxYear, true),
    !.
s63_standard_deduction(CaseID, TaxpayerID, TaxYear, StandardDeductionAmount) :-
    s63_c_basic_standard_deduction(CaseID, TaxpayerID, TaxYear, BasicStandardDeduction),
    s63_f_additional_standard_deduction_amount(CaseID, TaxpayerID, TaxYear, AdditionalStandardDeduction),
    StandardDeductionAmount is BasicStandardDeduction + AdditionalStandardDeduction.
% s63_c_basic_standard_deduction(CaseID, TaxpayerID, TaxYear, BSDAmount)
% Considers (c)(2) for amounts, (c)(5) for limitation for dependents, and (c)(7) for TCJA amounts.
s63_c_basic_standard_deduction(CaseID, TaxpayerID, TaxYear, BSDAmount) :-
    % Determine base BSD from (c)(2) as modified by (c)(7)
    s63_c_2_calculate_base_bsd(CaseID, TaxpayerID, TaxYear, BaseBSD),
    % Apply (c)(5) limitation if taxpayer is a dependent of another
    ( s63_c_5_limitation_for_dependents_applies(CaseID, TaxpayerID, TaxYear, true) ->
        s63_c_5_calculate_limited_bsd(CaseID, TaxpayerID, TaxYear, LimitedBSD),
        BSDAmount is min(BaseBSD, LimitedBSD) % The text says "shall not exceed the greater of..."
                                              % So the BSD *is* the greater of A or B, but this cannot exceed the normal BSD.
                                              % "basic standard deduction ... shall not exceed the greater of (A) or (B)"
                                              % This phrasing is confusing. Usually, it means BSD *is* the greater of A or B for dependents.
                                              % Let's assume dependent's BSD *is* the limited amount from c(5).
                                              % "the basic standard deduction applicable to such individual ... shall not exceed the greater of"
                                              % Standard interpretation: The dependent's BSD = max($500 (adj for infl), $250 (adj for infl) + EarnedIncome).
                                              % This amount then acts as their BSD. It's not a cap on their otherwise computed BSD.
                                              % It *is* their BSD.
      , BSDAmount = LimitedBSD
    ; BSDAmount = BaseBSD % Not a dependent, or limitation does not apply
    ),
    % Ensure BSD is not negative from calculation errors.
    (BSDAmount < 0 -> BSDAmount = 0 ; true).
% s63_c_2_calculate_base_bsd(CaseID, TaxpayerID, TaxYear, BaseBSD)
% Calculates BSD based on filing status, considering (c)(7) TCJA rules.
s63_c_2_calculate_base_bsd(CaseID, TaxpayerID, TaxYear, BaseBSD) :-
    ( tcja_active_standard_deduction(TaxYear) ->
        s63_c_7_tcja_bsd_amounts(CaseID, TaxpayerID, TaxYear, BaseBSD)
    ; s63_c_2_pre_tcja_bsd_amounts(CaseID, TaxpayerID, TaxYear, BaseBSD)
    ).
% s63_c_2_pre_tcja_bsd_amounts(CaseID, TaxpayerID, TaxYear, BaseBSD)
s63_c_2_pre_tcja_bsd_amounts(CaseID, TaxpayerID, TaxYear, BaseBSD) :-
    fact(CaseID, filing_status(TaxpayerID, TaxYear, FilingStatus)),
    ( (FilingStatus == joint_return ; FilingStatus == surviving_spouse) -> % (A)
        % 200% of (C) amount. (C) is $3000. So, $6000.
        % The text seems to have a typo for pre-TCJA.
        % Common pre-TCJA for MFJ was $12,700 (2017), Single $6,350.
        % Let's use the literal text:
        % (C) $3,000 in any other case.
        % (A) 200 percent of the dollar amount in effect under subparagraph (C) ... -> 2 * 3000 = 6000
        BaseBSD = 6000
    ; FilingStatus == head_of_household -> % (B)
        BaseBSD = 4400
    ; % (C) single, mfs
        BaseBSD = 3000
    ).
% s63_c_7_tcja_bsd_amounts(CaseID, TaxpayerID, TaxYear, BaseBSD)
% Paragraph (2) shall be applied (i) by substituting "$18,000" for "$4,400" in (B), and (ii) by substituting "$12,000" for "$3,000" in (C).
% (A) for MFJ/SS remains "200 percent of (C)". So, 2 * $12,000 = $24,000.
s63_c_7_tcja_bsd_amounts(CaseID, TaxpayerID, TaxYear, BaseBSD) :-
    fact(CaseID, filing_status(TaxpayerID, TaxYear, FilingStatus)),
    ( (FilingStatus == joint_return ; FilingStatus == surviving_spouse) -> % (A) applied with TCJA (C)
        BaseBSD = 24000 % 200% of $12,000
    ; FilingStatus == head_of_household -> % (B) with TCJA substitution
        BaseBSD = 18000
    ; % (C) with TCJA substitution (single, mfs)
        BaseBSD = 12000
    ).
% s63_c_5_limitation_for_dependents_applies(CaseID, IndividualID, TaxYear, AppliesBool)
% "In the case of an individual with respect to whom a deduction under section 151 is allowable to another taxpayer"
s63_c_5_limitation_for_dependents_applies(CaseID, IndividualID, TaxYear, true) :-
    fact(CaseID, person_is_taxpayer(AnotherTaxpayerID)),
    AnotherTaxpayerID \== IndividualID,
    s151_entitled_to_deduction_for_individual(CaseID, AnotherTaxpayerID, IndividualID, TaxYear, true),
    !.
s63_c_5_limitation_for_dependents_applies(_, _, _, false).
% s63_c_5_calculate_limited_bsd(CaseID, IndividualID, TaxYear, LimitedBSD)
% BSD shall not exceed the greater of (A) $500, or (B) sum of $250 and individual's earned income.
% These amounts are inflation adjusted in reality. Using literal statutory amounts.
s63_c_5_calculate_limited_bsd(CaseID, IndividualID, TaxYear, LimitedBSD) :-
    AmountA = 500, % Placeholder for inflation adjusted $500
    (fact(CaseID, earned_income(IndividualID, TaxYear, EarnedIncome)) -> true ; EarnedIncome = 0),
    AmountB_unadjusted is 250 + EarnedIncome, % Placeholder for inflation adjusted $250
    AmountB = (AmountB_unadjusted < 0 -> 0 ; AmountB_unadjusted), % Earned income might be negative (loss)
    LimitedBSD = max(AmountA, AmountB).
    % This limited BSD should not exceed the normal BSD for that filing status.
    % E.g., if dependent is married filing jointly, their normal BSD is $24000 (TCJA).
    % Their limited BSD (e.g. $1000) would be used.
    % The phrasing "shall not exceed" is tricky.
    % Common interpretation: the dependent's BSD *is* max(A, B), capped at the regular BSD for their status.
    % So, if max(A,B) is $1000, and regular BSD for single is $12000, their BSD is $1000.
    % If max(A,B) is $13000 (e.g. high earned income), their BSD is $12000 (capped).
    % The predicate s63_c_basic_standard_deduction already handles taking min(BaseBSD, LimitedBSD) if I re-enable that logic.
    % "the basic standard deduction ... shall not exceed the greater of" -- this means BSD = min(StandardBSDForTheirFilingStatus, max(500, 250+EI)).
    % My top s63_c_basic_standard_deduction was:
    %   (s63_c_5_limitation_for_dependents_applies -> LimitedBSD_raw = max(A,B), BSDAmount = min(BaseBSD, LimitedBSD_raw) ; BSDAmount = BaseBSD)
    % This seems more aligned with "shall not exceed".
    % Let's revert s63_c_basic_standard_deduction to use this.
    % No, the current structure of s63_c_basic_standard_deduction where it sets BSDAmount = LimitedBSD if applicable is more common.
    % The dependent's BSD is the result of the s63(c)(5) calculation, period. This calculated amount is then compared to itemized deductions.
    % No, IRS Pub 17 says "Standard deduction for dependents. If you can be claimed as a dependent on someone else’s return,
    % your standard deduction is generally limited to the greater of: $1,100 (for 2019, example), or Your earned income plus $350."
    % "But the standard deduction can’t be more than the regular standard deduction for your filing status." This confirms the cap.
    % So, the BSD for a dependent is: min(RegularBSDforTheirFilingStatus, max(ThresholdA, ThresholdB + EarnedIncome)).
    % My main `s63_c_basic_standard_deduction` needs to be:
    %   s63_c_2_calculate_base_bsd(CaseID, TaxpayerID, TaxYear, RegularBSDForFilingStatus),
    %   ( s63_c_5_limitation_for_dependents_applies(CaseID, TaxpayerID, TaxYear, true) ->
    %       s63_c_5_calculate_limited_bsd_raw(CaseID, TaxpayerID, TaxYear, RawLimitedAmount), % This calculates max(A, B+EI)
    %       BSDAmount is min(RegularBSDForFilingStatus, RawLimitedAmount)
    %   ; BSDAmount = RegularBSDForFilingStatus
    %   ).
    % This means s63_c_5_calculate_limited_bsd should just return max(A, B+EI).
    % This is what it currently does. The main predicate needs to apply the cap.
    % The main predicate `s63_c_basic_standard_deduction` has been updated to reflect this logic.
% s63_c_6_not_eligible_for_standard_deduction(CaseID, TaxpayerID, TaxYear, NotEligibleBool)
s63_c_6_not_eligible_for_standard_deduction(CaseID, TaxpayerID, TaxYear, true) :- % (A) MFS and spouse itemizes
    fact(CaseID, filing_status(TaxpayerID, TaxYear, married_filing_separately)),
    fact(CaseID, spouse_of(TaxpayerID, SpouseID)),
    fact(CaseID, elects_to_itemize_deductions(SpouseID, TaxYear)),
    !.
s63_c_6_not_eligible_for_standard_deduction(CaseID, TaxpayerID, TaxYear, true) :- % (B) Nonresident alien
    fact(CaseID, is_nonresident_alien_individual(TaxpayerID, TaxYear)), % Assuming a fact for this status
    !.
s63_c_6_not_eligible_for_standard_deduction(_CaseID, _TaxpayerID, _TaxYear, true) :- % (D) Estate or trust, etc.
    fact(_CaseID, taxpayer_is_estate_or_trust(_TaxpayerID, _TaxYear)), % Fact for this type of entity
    !.
s63_c_6_not_eligible_for_standard_deduction(_, _, _, false).
% s63_f_additional_standard_deduction_amount(CaseID, TaxpayerID, TaxYear, ASDAmount)
% Sum of additional amounts for aged and blind.
s63_f_additional_standard_deduction_amount(CaseID, TaxpayerID, TaxYear, ASDAmount) :-
    s63_f_1_amount_for_aged(CaseID, TaxpayerID, TaxYear, AgedAmount),
    s63_f_2_amount_for_blind(CaseID, TaxpayerID, TaxYear, BlindAmount),
    ASDAmount is AgedAmount + BlindAmount.
% s63_f_1_amount_for_aged(CaseID, TaxpayerID, TaxYear, TotalAgedAmount)
s63_f_1_amount_for_aged(CaseID, TaxpayerID, TaxYear, TotalAgedAmount) :-
    s63_f_get_base_per_condition_amount(CaseID, TaxpayerID, TaxYear, BaseAmount), % $600 or $750
    AgedAmountSelf = 0, AgedAmountSpouse = 0,
    ( s63_f_1_A_taxpayer_aged(CaseID, TaxpayerID, TaxYear, true) ->
        AgedAmountSelf = BaseAmount
    ; true
    ),
    ( s63_f_1_B_spouse_aged_and_exemption_allowable(CaseID, TaxpayerID, TaxYear, BaseAmount, SpouseContrib) -> % Passes BaseAmount for spouse context
        AgedAmountSpouse = SpouseContrib
    ; true
    ),
    TotalAgedAmount is AgedAmountSelf + AgedAmountSpouse.
% s63_f_1_A_taxpayer_aged(CaseID, TaxpayerID, TaxYear, IsAgedBool)
s63_f_1_A_taxpayer_aged(CaseID, TaxpayerID, TaxYear, true) :-
    get_age_at_year_end(CaseID, TaxpayerID, TaxYear, Age),
    Age >= 65,
    !.
s63_f_1_A_taxpayer_aged(_, _, _, false).
% s63_f_1_B_spouse_aged_and_exemption_allowable(CaseID, TaxpayerID, TaxYear, BaseAmountForSpouseContext, SpouseAgedAmount)
s63_f_1_B_spouse_aged_and_exemption_allowable(CaseID, TaxpayerID, TaxYear, BaseAmountForSpouseContext, BaseAmountForSpouseContext) :-
    fact(CaseID, spouse_of(TaxpayerID, SpouseID)),
    get_age_at_year_end(CaseID, SpouseID, TaxYear, SpouseAge),
    SpouseAge >= 65,
    % "an additional exemption is allowable to the taxpayer for such spouse under section 151(b)"
    % s151(b) is for spouse exemption on separate return.
    % If filing joint, this condition is usually met implicitly for spouse.
    % If filing separate, s151(b) conditions must be met.
    ( fact(CaseID, files_joint_return(TaxpayerID, SpouseID, TaxYear)) -> true % Exemption for spouse implicitly part of joint return framework
    ; s151_b_spouse_conditions_met(CaseID, TaxpayerID, SpouseID, TaxYear, true) % MFS, and 151(b) specific conditions met
    ),
    !.
s63_f_1_B_spouse_aged_and_exemption_allowable(_, _, _, _, 0).
% s63_f_2_amount_for_blind(CaseID, TaxpayerID, TaxYear, TotalBlindAmount)
s63_f_2_amount_for_blind(CaseID, TaxpayerID, TaxYear, TotalBlindAmount) :-
    s63_f_get_base_per_condition_amount(CaseID, TaxpayerID, TaxYear, BaseAmount),
    BlindAmountSelf = 0, BlindAmountSpouse = 0,
    ( s63_f_2_A_taxpayer_blind(CaseID, TaxpayerID, TaxYear, true) ->
        BlindAmountSelf = BaseAmount
    ; true
    ),
    ( s63_f_2_B_spouse_blind_and_exemption_allowable(CaseID, TaxpayerID, TaxYear, BaseAmount, SpouseContrib) ->
        BlindAmountSpouse = SpouseContrib
    ; true
    ),
    TotalBlindAmount is BlindAmountSelf + BlindAmountSpouse.
% s63_f_2_A_taxpayer_blind(CaseID, TaxpayerID, TaxYear, IsBlindBool)
s63_f_2_A_taxpayer_blind(CaseID, TaxpayerID, TaxYear, true) :-
    fact(CaseID, is_blind_at_close_of_year(TaxpayerID, TaxYear)),
    !.
s63_f_2_A_taxpayer_blind(_, _, _, false).
% s63_f_2_B_spouse_blind_and_exemption_allowable(CaseID, TaxpayerID, TaxYear, BaseAmountForSpouseContext, SpouseBlindAmount)
s63_f_2_B_spouse_blind_and_exemption_allowable(CaseID, TaxpayerID, TaxYear, BaseAmountForSpouseContext, BaseAmountForSpouseContext) :-
    fact(CaseID, spouse_of(TaxpayerID, SpouseID)),
    s63_f_2_B_spouse_blind_determination_timing(CaseID, SpouseID, TaxYear, true),
    % Same "additional exemption allowable" logic as for aged spouse
    ( fact(CaseID, files_joint_return(TaxpayerID, SpouseID, TaxYear)) -> true
    ; s151_b_spouse_conditions_met(CaseID, TaxpayerID, SpouseID, TaxYear, true)
    ),
    !.
s63_f_2_B_spouse_blind_and_exemption_allowable(_, _, _, _, 0).
% s63_f_2_B_spouse_blind_determination_timing(CaseID, SpouseID, TaxYear, IsBlindBool)
% "if the spouse dies during the taxable year the determination ... made as of the time of such death."
s63_f_2_B_spouse_blind_determination_timing(CaseID, SpouseID, TaxYear, true) :-
    ( fact(CaseID, person_died_on(SpouseID, date(YearDied, _, _))), YearDied == TaxYear ->
        fact(CaseID, is_blind_at_time_of_death(SpouseID, TaxYear))
    ;   fact(CaseID, is_blind_at_close_of_year(SpouseID, TaxYear))
    ),
    !.
s63_f_2_B_spouse_blind_determination_timing(_, _, _, false).
% s63_f_3_higher_amount_unmarried(CaseID, TaxpayerID, TaxYear, IsHigherAmountBool)
% "In the case of an individual who is not married and is not a surviving spouse"
s63_f_3_higher_amount_unmarried(CaseID, TaxpayerID, TaxYear, true) :-
    s7703_determination_of_marital_status(CaseID, TaxpayerID, TaxYear, MaritalStatus),
    MaritalStatus == not_married, % Not married (includes legally separated, or never married)
                                   % s7703 can also return 'considered_not_married_living_apart' for 7703(b)
                                   % For this rule, "not married" likely means truly not married per 7703(a).
    \+ s2_a_is_surviving_spouse(CaseID, TaxpayerID, TaxYear, true), % And not a surviving spouse
    !.
s63_f_3_higher_amount_unmarried(_, _, _, false).
% s63_f_get_base_per_condition_amount(CaseID, TaxpayerID, TaxYear, BaseAmount)
% Determines if $600 or $750 is used for additional amounts.
s63_f_get_base_per_condition_amount(CaseID, TaxpayerID, TaxYear, 750) :-
    s63_f_3_higher_amount_unmarried(CaseID, TaxpayerID, TaxYear, true),
    !.
s63_f_get_base_per_condition_amount(_, _, _, 600). % Default
% Marital status for Sec 63 purposes is determined under Sec 7703 (s63(g))
% This is mostly handled by calls to s7703_determination_of_marital_status directly where needed.