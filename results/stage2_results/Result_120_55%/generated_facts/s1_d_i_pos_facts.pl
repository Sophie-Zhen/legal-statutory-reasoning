% Stage 2 Generated Facts
% Case: s1_d_i_pos
% Text: Alice is married under section 7703 for the year 2017. Alice's taxable income for the year 2017 is $6662. Alice files taxes separately in 2017.
% Question: Alice has to pay $999 in taxes for the year 2017 under section 1(d)(i). Entailment

:- discontiguous s7703/2.
:- discontiguous s63/3.
:- discontiguous s1_d_i/2.
:- ['statutes/prolog/init'].
s7703("Alice",2017).
s63("Alice",2017,6662).
s1_d_i("Alice",2017).
