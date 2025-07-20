% Stage 2 Generated Facts
% Case: s3306_c_10_B_pos
% Text: Alice was paid $200 in March 2017 for services performed at Johns Hopkins Hospital in March 2017. Alice was a patient at Johns Hopkins Hospital from March 15th, 2017 to April 2nd, 2017.
% Question: Section 3306(c)(10)(B) applies to Alice's employment situation in 2017. Entailment

:- discontiguous payment_/1.
:- discontiguous agent_/2.
:- discontiguous patient_/2.
:- discontiguous amount_/2.
:- discontiguous start_/2.
:- discontiguous end_/2.
:- discontiguous service_/1.
:- discontiguous location_/2.
:- discontiguous patient_event_/1.
:- discontiguous hospital_/1.
:- ['statutes/prolog/init'].
payment_(span("paid",10,13)).
agent_(span("paid",10,13),span("Johns Hopkins Hospital",60,81)).
patient_(span("paid",10,13),span("Alice",0,4)).
amount_(span("paid",10,13),span(200,15,18)).
start_(span("paid",10,13),span(201703,23,32)).
end_(span("paid",10,13),span(201703,23,32)).
service_(span("services performed",38,55)).
agent_(span("services performed",38,55),span("Alice",0,4)).
location_(span("services performed",38,55),span("Johns Hopkins Hospital",60,81)).
start_(span("services performed",38,55),span(201703,86,95)).
end_(span("services performed",38,55),span(201703,86,95)).
patient_event_(span("patient",110,116)).
agent_(span("patient_event_",110,116),span("Alice",98,102)).
location_(span("patient_event_",110,116),span("Johns Hopkins Hospital",121,142)).
start_(span("patient_event_",110,116),span(20170315,148,164)).
end_(span("patient_event_",110,116),span(20170402,169,184)).
hospital_(span("Johns Hopkins Hospital",60,81)).
hospital_(span("Johns Hopkins Hospital",121,142)).
