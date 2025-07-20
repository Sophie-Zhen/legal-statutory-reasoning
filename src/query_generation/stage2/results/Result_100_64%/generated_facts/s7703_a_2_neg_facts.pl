% Stage 2 Generated Facts
% Case: s7703_a_2_neg
% Text: Alice and Bob got married on April 5th, 2012. Alice and Bob were legally separated under a decree of divorce on September 16th, 2017.
% Question: Section 7703(a)(2) applies to Alice for the year 2012. Contradiction

:- discontiguous marriage_/1.
:- discontiguous agent_/2.
:- discontiguous start_/2.
:- discontiguous divorce_/1.
:- ['statutes/prolog/init'].
marriage_(span("got married",14,24)).
agent_(span("got married",14,24),span("Alice",0,4)).
agent_(span("got married",14,24),span("Bob",10,12)).
start_(span("got married",14,24),span(20120405,29,44)).
divorce_(span("legally separated under a decree of divorce",66,109)).
agent_(span("legally separated under a decree of divorce",66,109),span("Alice",47,51)).
agent_(span("legally separated under a decree of divorce",66,109),span("Bob",57,59)).
start_(span("legally separated under a decree of divorce",66,109),span(20170916,114,135)).
