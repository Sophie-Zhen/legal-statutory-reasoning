% Stage 2 Generated Facts
% Case: s1_a_1_pos
% Text: Alice is married under section 7703 for the year 2017. Alice files a joint return with her spouse for 2017. Alice's and her husband's taxable income for the year 2017 is $17330.
% Question: Alice and her husband have to pay $2600 in taxes for the year 2017 under section 1(a). Entailment

:- discontiguous s7703_a_1/2.
:- discontiguous s6013_a/3.
:- discontiguous s63/3.
:- ['statutes/prolog/init'].
s7703_a_1("Alice",2017).
s6013_a("Alice","her husband",2017).
s63("Alice",2017,17330).
