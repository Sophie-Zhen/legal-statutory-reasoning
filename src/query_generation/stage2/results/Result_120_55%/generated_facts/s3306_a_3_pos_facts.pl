% Stage 2 Generated Facts
% Case: s3306_a_3_pos
% Text: Alice has paid $3200 in cash to Bob for agricultural labor done from Feb 1st, 2017 to Sep 2nd, 2017. Bob has paid $4200 in cash to Alice for domestic service in his home, done from Apr 1st, 2017 to Sep 1st, 2018.
% Question: Section 3306(a)(3) applies to Bob for the year 2018. Entailment

:- discontiguous payment_/1.
:- discontiguous agent_/2.
:- discontiguous recipient_/2.
:- discontiguous amount_/2.
:- discontiguous medium_/2.
:- discontiguous purpose_/2.
:- discontiguous start_/2.
:- discontiguous end_/2.
:- discontiguous location_/2.
:- ['statutes/prolog/init'].
payment_(span("paid",10,13)).
agent_(span("paid",10,13),span("Alice",0,4)).
recipient_(span("paid",10,13),span("Bob",30,32)).
amount_(span("paid",10,13),3200).
medium_(span("paid",10,13),span("cash",22,25)).
purpose_(span("paid",10,13),span("agricultural labor",38,55)).
start_(span("paid",10,13),span(20170201,67,80)).
end_(span("paid",10,13),span(20170902,85,98)).
payment_(span("paid",109,112)).
agent_(span("paid",109,112),span("Bob",101,103)).
recipient_(span("paid",109,112),span("Alice",129,133)).
amount_(span("paid",109,112),4200).
medium_(span("paid",109,112),span("cash",121,124)).
purpose_(span("paid",109,112),span("domestic service",139,154)).
location_(span("paid",109,112),span("his home",159,166)).
start_(span("paid",109,112),span(20170401,179,192)).
end_(span("paid",109,112),span(20180901,197,210)).
