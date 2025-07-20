% Stage 2 Generated Facts
% Case: s3306_c_5_pos
% Text: Alice has paid $3200 to her father Bob for work done from Feb 1st, 2017 to Sep 2nd, 2017, in Baltimore, Maryland, USA.
% Question: Section 3306(c)(5) applies to Alice employing Bob for the year 2017. Entailment

:- discontiguous agent_/2.
:- discontiguous patient_/2.
:- discontiguous amount_/2.
:- discontiguous purpose_/2.
:- discontiguous beneficiary_/2.
:- discontiguous start_/2.
:- discontiguous end_/2.
:- discontiguous location_/2.
:- ['statutes/prolog/init'].
father_(span("father",28,33)).
patient_(span("father",28,33),span("Alice",0,4)).
agent_(span("father",28,33),span("Bob",35,37)).
payment_(span("paid",10,13)).
agent_(span("paid",10,13),span("Alice",0,4)).
patient_(span("paid",10,13),span("Bob",35,37)).
amount_(span("paid",10,13),span(3200,15,19)).
purpose_(span("paid",10,13),span("work done",43,51)).
work_(span("work done",43,51)).
agent_(span("work done",43,51),span("Bob",35,37)).
beneficiary_(span("work done",43,51),span("Alice",0,4)).
start_(span("work done",43,51),span(20170201,58,71)).
end_(span("work done",43,51),span(20170902,76,89)).
location_(span("work done",43,51),span("Baltimore, Maryland, USA",95,119)).
