:- module(section68,
          [ s68_limitation_on_itemized_deductions/5, % s68_limitation_on_itemized_deductions(CaseID, TPID, TaxYear, AGI, GrossItemized, LimitedItemized)
            s68_b_applicable_amount/4                 % s68_b_applicable_amount(CaseID, TaxpayerID, TaxYear, ApplicableAmount)
          ]).

:- use_module(helpers, [tcja_s68_limitation_inactive/1]).
:- use_module(section2, [s2_a_is_surviving_spouse/4, s2_b_is_head_of_household/4]).
:- use_module(section7703, [s7703_is_married/4]).

:- dynamic fact/2.

% §68(f) Section not to apply
s68_limitation_on_itemized_deductions(_CaseID, _TPID, TaxYear, _AGI, GrossItemized, GrossItemized) :-
    tcja_s68_limitation_inactive(TaxYear).

% §68(a) General rule
s68_limitation_on_itemized_deductions(CaseID, TPID, TaxYear, AGI, GrossItemized, LimitedItemized) :-
    \+ tcja_s68_limitation_inactive(TaxYear),
    s68_b_applicable_amount(CaseID, TPID, TaxYear, ApplicableAmount),
    ( AGI =< ApplicableAmount ->
        LimitedItemized = GrossItemized
    ;
        ExcessAGI is AGI - ApplicableAmount,
        Reduction1 is 0.03 * ExcessAGI,
        Reduction2 is 0.80 * GrossItemized,
        Reduction is min(Reduction1, Reduction2),
        LimitedItemized is GrossItemized - Reduction,
        (LimitedItemized < 0 -> LimitedItemized = 0 ; true) % Ensure not negative
    ).

% §68(b) Applicable amount
s68_b_applicable_amount(CaseID, TPID, TaxYear, 300000) :- % (A)
    ( fact(CaseID, filing_status(TPID, TaxYear, married_filing_jointly))
    ; s2_a_is_surviving_spouse(CaseID, TPID, TaxYear, true)
    ).
s68_b_applicable_amount(CaseID, TPID, TaxYear, 275000) :- % (B)
    s2_b_is_head_of_household(CaseID, TPID, TaxYear, true).
s68_b_applicable_amount(CaseID, TPID, TaxYear, 250000) :- % (C)
    s7703_is_married(CaseID, TPID, TaxYear, false),
    s2_a_is_surviving_spouse(CaseID, TPID, TaxYear, false),
    s2_b_is_head_of_household(CaseID, TPID, TaxYear, false).
s68_b_applicable_amount(CaseID, TPID, TaxYear, 150000) :- % (D) MFS = 1/2 of (A)
    fact(CaseID, filing_status(TPID, TaxYear, married_filing_separately)).