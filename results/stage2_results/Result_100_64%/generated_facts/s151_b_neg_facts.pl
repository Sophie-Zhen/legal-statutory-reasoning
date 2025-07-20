% Stage 2 Generated Facts
% Case: s151_b_neg
% Text: Alice and Bob have been married since 2 Feb 2015. Bob has no income for 2015. Alice and Bob file their taxes jointly for 2015.
% Question: Alice can receive an exemption for Bob under section 151(b) for the year 2015. Contradiction

:- ['statutes/prolog/init'].
marriage_(span("married",23,29)).
agent_(span("married",23,29),span("Alice",0,4)).
agent_(span("married",23,29),span("Bob",10,12)).
start_(span("married",23,29),span(20150202,37,46)).
income_(span("income",59,64)).
agent_(span("income",59,64),span("Bob",49,51)).
amount_(span("income",59,64),0).
start_(span("income",59,64),span(2015,70,73)).
joint_return_(span("jointly",109,115)).
agent_(span("jointly",109,115),span("Alice",79,83)).
agent_(span("jointly",109,115),span("Bob",89,91)).
start_(span("jointly",109,115),span(2015,121,124)).
