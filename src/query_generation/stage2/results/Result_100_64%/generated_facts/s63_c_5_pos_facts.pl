% Stage 2 Generated Facts
% Case: s63_c_5_pos
% Text: In 2017, Alice was paid $33200. Alice and Bob have been married since Feb 3rd, 2017. Alice is entitled to a deduction for Bob under section 151(b). Bob had no gross income in 2017.
% Question: Under section 63(c)(5), Bob's basic standard deduction in 2017 is equal to at most $500. Entailment

:- discontiguous s151_b_applies/2.
:- ['statutes/prolog/init'].
s151_b_applies("Alice",2017).
income_(span("paid",22,25)).
agent_(span("paid",22,25),span("Alice",10,14)).
amount_(span("paid",22,25),span(33200,28,32)).
start_(span("paid",22,25),span(2017,3,6)).
marriage_(span("married",60,66)).
agent_(span("married",60,66),span("Alice",35,39)).
agent_(span("married",60,66),span("Bob",45,47)).
start_(span("married",60,66),span(20170203,74,86)).
income_(span("gross income",157,168)).
agent_(span("gross income",157,168),span("Bob",144,146)).
amount_(span("gross income",157,168),span(0,151,152)).
start_(span("gross income",157,168),span(2017,173,176)).
