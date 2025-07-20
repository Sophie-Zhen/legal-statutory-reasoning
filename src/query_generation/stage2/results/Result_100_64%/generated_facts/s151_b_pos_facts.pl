% Stage 2 Generated Facts
% Case: s151_b_pos
% Text: Alice and Bob have been married since 2 Feb 2015. Bob has no income for 2015.
% Question: Alice can receive an exemption for Bob under section 151(b) for the year 2015. Entailment

:- ['statutes/prolog/init'].
marriage_(span("married",25,31)).
agent_(span("married",25,31),span("Alice",0,4)).
agent_(span("married",25,31),span("Bob",10,12)).
start_(span("married",25,31),span(20150202,38,47)).
income_(span("income",59,64)).
agent_(span("income",59,64),span("Bob",49,51)).
amount_(span("income",59,64),span(0,56,57)).
start_(span("income",59,64),span(2015,70,73)).
