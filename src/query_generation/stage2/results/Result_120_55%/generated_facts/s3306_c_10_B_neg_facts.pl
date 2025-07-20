% Stage 2 Generated Facts
% Case: s3306_c_10_B_neg
% Text: Alice was paid $200 in March 2017 for services performed at Johns Hopkins Hospital in March 2017. Alice was a patient at Johns Hopkins Hospital from January 12th, 2017 to February 20th, 2017.
% Question: Section 3306(c)(10)(B) applies to Alice's employment situation in 2017. Contradiction

:- discontiguous agent_/2.
:- discontiguous patient_/2.
:- discontiguous amount_/2.
:- discontiguous location_/2.
:- discontiguous start_/2.
:- discontiguous end_/2.
:- ['statutes/prolog/init'].
payment_(span("paid",10,13)).
patient_(span("paid",10,13),span("Alice",0,4)).
amount_(span("paid",10,13),200).
start_(span("paid",10,13),span(201703,23,32)).
services_performed_(span("services performed",38,55)).
agent_(span("services performed",38,55),span("Alice",0,4)).
location_(span("services performed",38,55),span("Johns Hopkins Hospital",60,81)).
start_(span("services performed",38,55),span(201703,86,95)).
patient_(span("patient",108,114)).
agent_(span("patient",108,114),span("Alice",98,102)).
location_(span("patient",108,114),span("Johns Hopkins Hospital",119,140)).
start_(span("patient",108,114),span(20170112,147,166)).
end_(span("patient",108,114),span(20170220,171,190)).
