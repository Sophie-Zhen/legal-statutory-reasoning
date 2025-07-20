% Stage 2 Generated Facts
% Case: s1_b_neg
% Text: Alice is married under section 7703 for the year 2017. Alice's taxable income for the year 2017 is $554313. Alice files a separate return from her spouse.
% Question: Alice has to pay $207772 in taxes for the year 2017 under section 1(b). Contradiction

:- discontiguous s63/3.
:- discontiguous s7703_a_1/3.
:- discontiguous s1_d_1/2.
:- ['statutes/prolog/init'].
s7703_a_1("Alice",_,2017).
s63("Alice",2017,554313).
s1_d_1("Alice",2017).
