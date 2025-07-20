% Stage 2 Generated Facts
% Case: s1_d_ii_neg
% Text: Alice is married under section 7703 for the year 2017. Alice's taxable income for the year 2017 is $113580. Alice files a separate return.
% Question: Alice has to pay $33653 in taxes for the year 2017 under section 1(d)(ii). Contradiction

:- discontiguous s7703_a_applies/2.
:- discontiguous s63/3.
:- discontiguous s1_d_applies/2.
:- ['statutes/prolog/init'].
s7703_a_applies("Alice",2017).
s63("Alice",2017,113580).
s1_d_applies("Alice",2017).
