:- module(section68,
          [
            s68_apply_limitation/6, % s68_apply_limitation(CaseID, TaxpayerID, TaxYear, AGI, GrossItemized, LimitedItemized)
            s68_b_applicable_amount/4 % s68_b_applicable_amount(CaseID, TaxpayerID, TaxYear, ApplicableAmount)
          ]).

:- use_module(section2, [s2_a_is_surviving_spouse/3, s2_b_is_head_of_household/3]).
:- use_module(section7703, [s7703_is_married_gen_rule/3]). % For marital status
:- use_module(helpers, [tcja_active/1]).


% (f) Section not to apply for 2018-2025
s68_apply_limitation(_CaseID, _TaxpayerID, TaxYear, _AGI, GrossItemized, GrossItemized) :-
    tcja_active(TaxYear).

% (a) General rule for limitation (pre-2018, post-2025)
s68_apply_limitation(CaseID, TaxpayerID, TaxYear, AGI, GrossItemized, LimitedItemized) :-
    \+ tcja_active(TaxYear),
    s68_b_applicable_amount(CaseID, TaxpayerID, TaxYear, ApplicableAmount),
    ( AGI =< ApplicableAmount ->
        LimitedItemized = GrossItemized % No limitation if AGI not over applicable amount
    ;
        ExcessAGI is AGI - ApplicableAmount,
        Reduction1 is 0.03 * ExcessAGI,
        Reduction2 is 0.80 * GrossItemized,
        ReductionAmount is min(Reduction1, Reduction2),
        LimitedItemized is GrossItemized - ReductionAmount
    ).

% (b) Applicable amount
s68_b_applicable_amount(CaseID, TaxpayerID, TaxYear, Amount) :-
    fact(CaseID, filing_status(TaxpayerID, TaxYear, married_filing_jointly)),
    Amount = 300000. % (A)
s68_b_applicable_amount(CaseID, TaxpayerID, TaxYear, Amount) :-
    s2_a_is_surviving_spouse(CaseID, TaxpayerID, TaxYear), % Check if surviving spouse
    Amount = 300000. % (A)
s68_b_applicable_amount(CaseID, TaxpayerID, TaxYear, Amount) :-
    s2_b_is_head_of_household(CaseID, TaxpayerID, TaxYear), % Check if head of household
    Amount = 275000. % (B)
s68_b_applicable_amount(CaseID, TaxpayerID, TaxYear, Amount) :-
    \+ s7703_is_married_gen_rule(CaseID, TaxpayerID, TaxYear), % Not married
    \+ s2_a_is_surviving_spouse(CaseID, TaxpayerID, TaxYear), % Not SS
    \+ s2_b_is_head_of_household(CaseID, TaxpayerID, TaxYear), % Not HoH
    Amount = 250000. % (C) Single
s68_b_applicable_amount(CaseID, TaxpayerID, TaxYear, Amount) :-
    fact(CaseID, filing_status(TaxpayerID, TaxYear, married_filing_separately)),
    Amount is 300000 / 2. % (D) 1/2 of (A)