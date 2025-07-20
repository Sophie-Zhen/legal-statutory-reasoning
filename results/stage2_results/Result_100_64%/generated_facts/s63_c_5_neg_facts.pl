% Stage 2 Generated Facts
% Case: s63_c_5_neg
% Text: In 2017, Alice was paid $33200. Alice and Bob have been married since Feb 3rd, 2017. Bob earned $10 in 2017. Alice and Bob file separate returns. Alice is not entitled to a deduction for Bob under section 151.
% Question: Section 63(c)(5) applies to Bob's basic standard deduction in 2017. Contradiction

:- ['statutes/prolog/init'].
payment_(span("paid",19,22)).
patient_(span("paid",19,22),span("Alice",11,15)).
amount_(span("paid",19,22),span(33200,24,28)).
start_(span("paid",19,22),span(2017,3,6)).
marriage_(span("married",54,60)).
agent_(span("married",54,60),span("Alice",31,35)).
agent_(span("married",54,60),span("Bob",41,43)).
start_(span("married",54,60),span(20170203,67,79)).
income_(span("earned",86,91)).
agent_(span("earned",86,91),span("Bob",82,84)).
amount_(span("earned",86,91),span(10,94,95)).
start_(span("earned",86,91),span(2017,100,103)).
