% Stage 2 Generated Facts
% Case: s63_f_1_B_neg
% Text: In 2017, Alice was paid $33200. Alice and Bob have been married since Feb 3rd, 2017. Alice was born March 2nd, 1950 and Bob was born March 3rd, 1955. In addition, Alice is allowed an exemption for Bob under section 151(b) for the year 2017.
% Question: Section 63(f)(1)(B) applies to Alice with Bob as the spouse in 2017. Contradiction

:- discontiguous s151_b_applies/2.
:- ['statutes/prolog/init'].
s151_b_applies("Alice",2017).
payment_(span("paid",21,24)).
agent_(span("paid",21,24),span("Alice",10,14)).
amount_(span("paid",21,24),span(33200,26,31)).
start_(span("paid",21,24),span(2017,3,6)).
marriage_(span("married",58,64)).
patient_(span("married",58,64),span("Alice",34,38)).
patient_(span("married",58,64),span("Bob",44,46)).
start_(span("married",58,64),span(20170203,66,78)).
birth_(span("born",91,94)).
agent_(span("born",91,94),span("Alice",81,85)).
start_(span("born",91,94),span(19500302,96,110)).
birth_(span("born",120,123)).
agent_(span("born",120,123),span("Bob",116,118)).
start_(span("born",120,123),span(19550303,125,139)).
