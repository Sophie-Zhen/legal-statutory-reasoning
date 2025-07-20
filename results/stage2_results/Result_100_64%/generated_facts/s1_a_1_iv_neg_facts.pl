% Stage 2 Generated Facts
% Case: s1_a_1_iv_neg
% Text: Alice is married under section 7703 for the year 2017. Alice files a joint return with her spouse for 2017. Alice's and her spouse's taxable income for the year 2017 is $684642.
% Question: Alice and her spouse have to pay $247647 in taxes for the year 2017 under section 1(a)(iv). Contradiction

:- discontiguous s7703_a_1/3.
:- discontiguous s6013_a/3.
:- discontiguous s63/3.
:- ['statutes/prolog/init'].
s7703_a_1("Alice",_,2017).
s6013_a("Alice",_,2017).
s63("Alice",2017,684642).
