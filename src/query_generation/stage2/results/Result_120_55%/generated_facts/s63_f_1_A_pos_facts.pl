% Stage 2 Generated Facts
% Case: s63_f_1_A_pos
% Text: In 2017, Alice was paid $33200. Alice and Bob have been married since Feb 3rd, 2017. Alice was born March 2nd, 1950 and Bob was born March 3rd, 1955.
% Question: Section 63(f)(1)(A) applies to Alice in 2017. Entailment

:- discontiguous agent_/2.
:- discontiguous birth_/1.
:- discontiguous start_/2.
:- ['statutes/prolog/init'].
payment_(span("paid",21,24)).
agent_(span("paid",21,24),span("Alice",10,14)).
amount_(span("paid",21,24),span(33200,26,31)).
start_(span("paid",21,24),span(2017,3,6)).
marriage_(span("married",58,64)).
agent_(span("married",58,64),span("Alice",33,37)).
agent_(span("married",58,64),span("Bob",43,45)).
start_(span("married",58,64),span(20170203,71,83)).
birth_(span("born",96,99)).
agent_(span("born",96,99),span("Alice",86,90)).
start_(span("born",96,99),span(19500302,101,116)).
birth_(span("born",126,129)).
agent_(span("born",126,129),span("Bob",121,123)).
start_(span("born",126,129),span(19550303,131,146)).
