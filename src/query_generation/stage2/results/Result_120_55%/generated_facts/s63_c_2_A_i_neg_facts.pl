% Stage 2 Generated Facts
% Case: s63_c_2_A_i_neg
% Text: In 2017, Alice was paid $33200 in remuneration. Alice and Bob have been married since Feb 3rd, 2017. Alice and Bob file separate returns in 2017.
% Question: Section 63(c)(2)(A)(i) applies to Alice in 2017. Contradiction

:- ['statutes/prolog/init'].
payment_(span("paid",20,23)).
agent_(span("paid",20,23),span("Alice",10,14)).
amount_(span("paid",20,23),span(33200,25,29)).
start_(span("paid",20,23),span(2017,3,6)).
marriage_(span("married",65,71)).
agent_(span("married",65,71),span("Alice",49,53)).
agent_(span("married",65,71),span("Bob",59,61)).
start_(span("married",65,71),span(20170203,78,90)).
filing_separate_returns_(span("file separate returns",108,128)).
agent_(span("file separate returns",108,128),span("Alice",93,97)).
agent_(span("file separate returns",108,128),span("Bob",103,105)).
start_(span("file separate returns",108,128),span(2017,133,136)).
