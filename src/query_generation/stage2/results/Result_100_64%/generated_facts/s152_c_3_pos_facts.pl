% Stage 2 Generated Facts
% Case: s152_c_3_pos
% Text: Alice was born January 10th, 1992. Bob was born January 31st, 2014. Alice adopted Bob on March 4th, 2018.
% Question: Bob satisfies section 152(c)(3) with Alice claiming Bob as a qualifying child for the year 2019. Entailment

:- discontiguous birth_/1.
:- discontiguous agent_/2.
:- discontiguous start_/2.
:- ['statutes/prolog/init'].
birth_(span("born",10,13)).
agent_(span("born",10,13),span("Alice",0,4)).
start_(span("born",10,13),span(19920110,15,32)).
birth_(span("born",43,46)).
agent_(span("born",43,46),span("Bob",35,37)).
start_(span("born",43,46),span(20140131,48,65)).
adoption_(span("adopted",74,80)).
agent_(span("adopted",74,80),span("Alice",68,72)).
patient_(span("adopted",74,80),span("Bob",82,84)).
start_(span("adopted",74,80),span(20180304,89,104)).
