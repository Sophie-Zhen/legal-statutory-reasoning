% Stage 2 Generated Facts
% Case: s1_c_neg
% Text: Alice is married under section 7703 for the year 2017. Alice files a joint return with her spouse for 2017. Alice's and her spouse's taxable income for the year 2017 is $17330.
% Question: Alice and her spouse have to pay $2600 in taxes for the year 2017 under section 1(c). Contradiction

:- discontiguous s63/3.
:- discontiguous s7703_a/2.
:- discontiguous s6013_a/2.
:- ['statutes/prolog/init'].
s7703_a("Alice",2017).
s6013_a("Alice",2017).
s63("Alice",2017,17330).
