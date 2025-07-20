% Stage 2 Generated Facts
% Case: s63_c_6_B_pos
% Text: In 2017, Alice was paid $33200. Alice and Bob got married on Feb 3rd, 2017. Alice was a nonresident alien from August 23rd, 2016 to September 15th, 2018.
% Question: Section 63(c)(6)(B) applies to Alice for 2017. Entailment

:- discontiguous s63_c_6_B_applies/2.
:- ['statutes/prolog/init'].
payment_(span("paid",21,24)).
agent_(span("paid",21,24),span("Alice",10,14)).
amount_(span("paid",21,24),span(33200,26,31)).
start_(span("paid",21,24),span(2017,3,6)).
marriage_(span("married",51,57)).
agent_(span("married",51,57),span("Alice",34,38)).
agent_(span("married",51,57),span("Bob",44,46)).
start_(span("married",51,57),span(20170203,62,74)).
nonresident_alien_(span("nonresident alien",88,104)).
agent_(span("nonresident alien",88,104),span("Alice",77,81)).
start_(span("nonresident alien",88,104),span(20160823,111,129)).
end_(span("nonresident alien",88,104),span(20180915,134,154)).
s63_c_6_B_applies("Alice",2017).
