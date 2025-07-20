% alice_tax_test.pl
% Self-contained test for Alice's 2017 tax liability under §1(a)(iv)

:- module(alice_tax_test, [answer/1]).
:- use_module(section1).
:- use_module(section7703).

% -- Case facts for Alice in 2017 --
agent_(ev_alice_2017, alice).
married_individual_(alice).
filed_joint_return(ev_alice_2017, alice).

% -- Query predicate -------------------------------------------------------
% answer(Result).
% Result = true  if Alice and her spouse pay exactly $44,789 under §1(a)(iv)
% Result = false otherwise.
answer(Result) :-
    % Given taxable income for Alice and spouse
    TaxableIncome = 164612,
    % Expected tax amount per question
    ExpectedTax = 44789,
    % Compute tax via §1(a) bracket rules
    s1_a_1(ev_alice_2017, TaxableIncome, TaxFloat),
    % Round to nearest dollar
    RoundTax is round(TaxFloat),
    % Compare to expected
    ( RoundTax =:= ExpectedTax -> Result = true ; Result = false ).
