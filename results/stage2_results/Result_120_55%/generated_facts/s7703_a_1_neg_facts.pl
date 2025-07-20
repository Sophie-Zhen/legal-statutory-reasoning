% Stage 2 Generated Facts
% Case: s7703_a_1_neg
% Text: Alice and Bob got married on April 5th, 2012. Bob died September 16th, 2017.
% Question: Section 7703(a)(1) applies to Alice for the year 2018. Contradiction

:- discontiguous s7703_a_1_applies/2.
:- ['statutes/prolog/init'].
marriage_(span("married",18,24)).
agent_(span("married",18,24),span("Alice",0,4)).
agent_(span("married",18,24),span("Bob",10,12)).
start_(span("married",18,24),span(20120405,29,44)).
death_(span("died",51,54)).
agent_(span("died",51,54),span("Bob",47,49)).
start_(span("died",51,54),span(20170916,56,78)).
s7703_a_1_applies("Alice",2018).
