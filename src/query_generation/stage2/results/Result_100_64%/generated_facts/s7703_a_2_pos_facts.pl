% Stage 2 Generated Facts
% Case: s7703_a_2_pos
% Text: Alice and Bob got married on April 5th, 2012. Alice and Bob were legally separated under a decree of divorce on September 16th, 2017.
% Question: Section 7703(a)(2) applies to Alice for the year 2018. Entailment

:- ['statutes/prolog/init'].
marriage_(span("married",18,24)).
agent_(span("married",18,24),span("Alice",0,4)).
agent_(span("married",18,24),span("Bob",10,12)).
start_(span("married",18,24),span(20120405,29,44)).
divorce_(span("decree of divorce",90,106)).
agent_(span("decree of divorce",90,106),span("Alice",47,51)).
agent_(span("decree of divorce",90,106),span("Bob",57,59)).
start_(span("decree of divorce",90,106),span(20170916,111,132)).
