% Stage 2 Generated Facts
% Case: s63_c_6_B_neg
% Text: In 2017, Alice was paid $33200. Alice and Bob got married on Feb 3rd, 2017. Alice was a nonresident alien from August 23rd, 2015 to September 15th, 2016.
% Question: Section 63(c)(6)(B) applies to Alice for 2017. Contradiction

:- discontiguous nonresident_alien_/1.
:- discontiguous marriage_/1.
:- discontiguous payment_/1.
:- discontiguous agent_/2.
:- discontiguous amount_/2.
:- discontiguous start_/2.
:- discontiguous end_/2.
:- discontiguous participant_/2.
:- ['statutes/prolog/init'].
payment_(span("paid",21,24)).
agent_(span("paid",21,24),span("Alice",10,14)).
amount_(span("paid",21,24),span(33200,26,31)).
start_(span("paid",21,24),span(2017,3,6)).
end_(span("paid",21,24),span(2017,3,6)).
marriage_(span("married",49,55)).
participant_(span("married",49,55),span("Alice",34,38)).
participant_(span("married",49,55),span("Bob",44,46)).
start_(span("married",49,55),span(20170203,60,71)).
nonresident_alien_(span("nonresident alien",86,102)).
agent_(span("nonresident alien",86,102),span("Alice",74,78)).
start_(span("nonresident alien",86,102),span(20150823,109,125)).
end_(span("nonresident alien",86,102),span(20160915,130,149)).
