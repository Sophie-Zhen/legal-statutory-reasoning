% Stage 2 Generated Facts
% Case: s3306_c_6_pos
% Text: Alice was paid $73200 in 2017 as an employee of the United States Government in Arlington, Virginia, USA.
% Question: Section 3306(c)(6) applies to Alice's employment situation in 2017. Entailment

:- discontiguous income_/1.
:- discontiguous agent_/2.
:- discontiguous amount_/2.
:- discontiguous start_/2.
:- discontiguous employment_/1.
:- discontiguous patient_/2.
:- discontiguous location_/2.
:- ['statutes/prolog/init'].
income_(span("paid",9,12)).
agent_(span("paid",9,12),span("Alice",0,4)).
amount_(span("paid",9,12),span(73200,14,19)).
start_(span("paid",9,12),span(2017,24,27)).
employment_(span("employee",35,42)).
agent_(span("employee",35,42),span("Alice",0,4)).
patient_(span("employee",35,42),span("United States Government",47,72)).
start_(span("employee",35,42),span(2017,24,27)).
location_(span("employee",35,42),span("Arlington, Virginia, USA",77,101)).
