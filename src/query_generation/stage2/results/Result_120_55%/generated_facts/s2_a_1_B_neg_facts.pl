% Stage 2 Generated Facts
% Case: s2_a_1_B_neg
% Text: Alice and Bob were married from Feb 3rd, 1992 to Jan 14th, 2020. Alice has a child, Charlie, born October 9th, 2000. Alice died on July 9th, 2021. From 2011 to 2024, Bob furnished the costs of maintaining the home where he and Charlie lived during that time. In 2020, Charlie filed a joint return with his spouse whom he married on Dec 1st, 2020. Charlie earned $312489 in 2020.
% Question: Section 2(a)(1)(B) applies to Bob in 2020. Contradiction

:- discontiguous marriage_/1.
:- discontiguous child_/1.
:- discontiguous birth_/1.
:- discontiguous death_/1.
:- discontiguous payment_/1.
:- discontiguous residence_/1.
:- discontiguous return_/1.
:- discontiguous income_/1.
:- discontiguous agent_/2.
:- discontiguous patient_/2.
:- discontiguous start_/2.
:- discontiguous end_/2.
:- discontiguous amount_/2.
:- ['statutes/prolog/init'].
marriage_(span("married",19,25)).
agent_(span("married",19,25),span("Alice",0,4)).
agent_(span("married",19,25),span("Bob",10,12)).
start_(span("married",19,25),span(19920203,32,44)).
end_(span("married",19,25),span(20200114,49,62)).
child_(span("child",77,81)).
patient_(span("child",77,81),span("Alice",65,69)).
agent_(span("child",77,81),span("Charlie",84,90)).
birth_(span("born",93,96)).
agent_(span("born",93,96),span("Charlie",84,90)).
start_(span("born",93,96),span(20001009,98,115)).
death_(span("died",124,127)).
agent_(span("died",124,127),span("Alice",118,122)).
start_(span("died",124,127),span(20210709,132,146)).
payment_(span("furnished",172,180)).
agent_(span("furnished",172,180),span("Bob",168,170)).
start_(span("furnished",172,180),span(2011,154,157)).
end_(span("furnished",172,180),span(2024,162,165)).
residence_(span("home",210,213)).
agent_(span("home",210,213),span("Bob",168,170)).
agent_(span("home",210,213),span("Charlie",228,234)).
start_(span("home",210,213),span(2011,154,157)).
end_(span("home",210,213),span(2024,162,165)).
return_(span("joint return",283,294)).
agent_(span("joint return",283,294),span("Charlie",269,275)).
agent_(span("joint return",283,294),span("spouse",302,307)).
start_(span("joint return",283,294),span(2020,263,266)).
marriage_(span("married",318,324)).
agent_(span("married",318,324),span("Charlie",269,275)).
agent_(span("married",318,324),span("spouse",302,307)).
start_(span("married",318,324),span(20201201,329,342)).
income_(span("earned",353,358)).
agent_(span("earned",353,358),span("Charlie",345,351)).
amount_(span("earned",353,358),312489).
start_(span("earned",353,358),span(2020,371,374)).
