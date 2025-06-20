:- module(section1,
          [ s1_tax_imposed/5, % s1_tax_imposed(CaseID, TaxpayerID, TaxYear, TaxableIncome, Tax)
            s1_a_tax_mfj_ss/2, % s1_a_tax_mfj_ss(TaxableIncome, Tax) - specific subsection rates
            s1_b_tax_hoh/2,    % s1_b_tax_hoh(TaxableIncome, Tax)
            s1_c_tax_single/2, % s1_c_tax_single(TaxableIncome, Tax)
            s1_d_tax_mfs/2     % s1_d_tax_mfs(TaxableIncome, Tax)
          ]).

:- use_module(helpers, [round_to_dollars/2]).
:- use_module(section2, []). % For definitions like surviving_spouse, head_of_household
:- use_module(section7703, []). % For married definition

:- dynamic fact/2. % fact(CaseID, FactAtom) - for filing_status

s1_tax_imposed(CaseID, TaxpayerID, TaxYear, TaxableIncome, Tax) :-
    fact(CaseID, filing_status(TaxpayerID, TaxYear, married_filing_jointly)),
    s1_a_tax_mfj_ss(TaxableIncome, RawTax),
    round_to_dollars(RawTax, Tax).
s1_tax_imposed(CaseID, TaxpayerID, TaxYear, TaxableIncome, Tax) :-
    fact(CaseID, filing_status(TaxpayerID, TaxYear, surviving_spouse)),
    s1_a_tax_mfj_ss(TaxableIncome, RawTax),
    round_to_dollars(RawTax, Tax).
s1_tax_imposed(CaseID, TaxpayerID, TaxYear, TaxableIncome, Tax) :-
    fact(CaseID, filing_status(TaxpayerID, TaxYear, head_of_household)),
    s1_b_tax_hoh(TaxableIncome, RawTax),
    round_to_dollars(RawTax, Tax).
s1_tax_imposed(CaseID, TaxpayerID, TaxYear, TaxableIncome, Tax) :-
    fact(CaseID, filing_status(TaxpayerID, TaxYear, single)),
    s1_c_tax_single(TaxableIncome, RawTax),
    round_to_dollars(RawTax, Tax).
s1_tax_imposed(CaseID, TaxpayerID, TaxYear, TaxableIncome, Tax) :-
    fact(CaseID, filing_status(TaxpayerID, TaxYear, married_filing_separately)),
    s1_d_tax_mfs(TaxableIncome, RawTax),
    round_to_dollars(RawTax, Tax).

% §1(a) Married individuals filing joint returns and surviving spouses
s1_a_tax_mfj_ss(TI, Tax) :- TI =< 36900, Tax is 0.15 * TI.
s1_a_tax_mfj_ss(TI, Tax) :- TI > 36900,  TI =< 89150,  Tax is 5535 + 0.28 * (TI - 36900).
s1_a_tax_mfj_ss(TI, Tax) :- TI > 89150,  TI =< 140000, Tax is 20165 + 0.31 * (TI - 89150).
s1_a_tax_mfj_ss(TI, Tax) :- TI > 140000, TI =< 250000, Tax is 35928.50 + 0.36 * (TI - 140000).
s1_a_tax_mfj_ss(TI, Tax) :- TI > 250000, Tax is 75528.50 + 0.396 * (TI - 250000).

% §1(b) Heads of households
s1_b_tax_hoh(TI, Tax) :- TI =< 29600, Tax is 0.15 * TI.
s1_b_tax_hoh(TI, Tax) :- TI > 29600,  TI =< 76400,  Tax is 4440 + 0.28 * (TI - 29600).
s1_b_tax_hoh(TI, Tax) :- TI > 76400,  TI =< 127500, Tax is 17544 + 0.31 * (TI - 76400).
s1_b_tax_hoh(TI, Tax) :- TI > 127500, TI =< 250000, Tax is 33385 + 0.36 * (TI - 127500).
s1_b_tax_hoh(TI, Tax) :- TI > 250000, Tax is 77485 + 0.396 * (TI - 250000).

% §1(c) Unmarried individuals
s1_c_tax_single(TI, Tax) :- TI =< 22100, Tax is 0.15 * TI.
s1_c_tax_single(TI, Tax) :- TI > 22100,  TI =< 53500,  Tax is 3315 + 0.28 * (TI - 22100).
s1_c_tax_single(TI, Tax) :- TI > 53500,  TI =< 115000, Tax is 12107 + 0.31 * (TI - 53500).
s1_c_tax_single(TI, Tax) :- TI > 115000, TI =< 250000, Tax is 31172 + 0.36 * (TI - 115000).
s1_c_tax_single(TI, Tax) :- TI > 250000, Tax is 79772 + 0.396 * (TI - 250000).

% §1(d) Married individuals filing separate returns
s1_d_tax_mfs(TI, Tax) :- TI =< 18450, Tax is 0.15 * TI.
s1_d_tax_mfs(TI, Tax) :- TI > 18450,  TI =< 44575,  Tax is 2767.50 + 0.28 * (TI - 18450).
s1_d_tax_mfs(TI, Tax) :- TI > 44575,  TI =< 70000,  Tax is 10082.50 + 0.31 * (TI - 44575).
s1_d_tax_mfs(TI, Tax) :- TI > 70000,  TI =< 125000, Tax is 17964.25 + 0.36 * (TI - 70000).
s1_d_tax_mfs(TI, Tax) :- TI > 125000, Tax is 37764.25 + 0.396 * (TI - 125000).