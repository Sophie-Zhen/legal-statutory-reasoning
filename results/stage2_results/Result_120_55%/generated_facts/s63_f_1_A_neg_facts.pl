% Stage 2 Generated Facts
% Case: s63_f_1_A_neg
% Text: In 2017, Alice was paid $33200. Alice and Bob have been married since Feb 3rd, 2017. Alice was born March 2nd, 1950 and Bob was born March 3rd, 1955.
% Question: Section 63(f)(1)(A) applies to Bob in 2017. Contradiction

:- ['statutes/prolog/init'].
income_(span("paid",22,25)).
patient_(span("paid",22,25),span("Alice",10,14)).
amount_(span("paid",22,25),span(33200,27,32)).
start_(span("paid",22,25),span(2017,3,6)).
marriage_(span("married",59,65)).
agent_(span("married",59,65),span("Alice",35,39)).
agent_(span("married",59,65),span("Bob",45,47)).
start_(span("married",59,65),span(20170203,72,85)).
birth_(span("born",98,101)).
agent_(span("born",98,101),span("Alice",88,92)).
start_(span("born",98,101),span(19500302,103,118)).
birth_(span("born",132,135)).
agent_(span("born",132,135),span("Bob",124,126)).
start_(span("born",132,135),span(19550303,137,152)).
