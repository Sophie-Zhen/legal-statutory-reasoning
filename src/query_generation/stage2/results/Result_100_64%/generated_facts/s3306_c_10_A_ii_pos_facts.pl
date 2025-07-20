% Stage 2 Generated Facts
% Case: s3306_c_10_A_ii_pos
% Text: Alice's husband, Bob, was paid $3200 in 2017 for services performed for Johns Hopkins University. Alice was enrolled at Johns Hopkins University and attending classes from August 29, 2015 to May 30th, 2019.
% Question: Section 3306(c)(10)(A)(ii) applies to Bob's employment situation in 2017. Entailment

:- discontiguous agent_/2.
:- discontiguous patient_/2.
:- discontiguous start_/2.
:- ['statutes/prolog/init'].
husband_(span("husband",8,14)).
patient_(span("husband",8,14),span("Alice",0,4)).
agent_(span("husband",8,14),span("Bob",17,19)).
income_(span("paid",26,29)).
agent_(span("paid",26,29),span("Bob",17,19)).
amount_(span("paid",26,29),span(3200,31,35)).
start_(span("paid",26,29),span(2017,40,43)).
purpose_(span("paid",26,29),span("services performed",49,66)).
service_(span("services performed",49,66)).
agent_(span("services performed",49,66),span("Bob",17,19)).
patient_(span("services performed",49,66),span("Johns Hopkins University",72,95)).
start_(span("services performed",49,66),span(2017,40,43)).
enrollment_(span("enrolled",108,115)).
agent_(span("enrolled",108,115),span("Alice",98,102)).
patient_(span("enrolled",108,115),span("Johns Hopkins University",120,143)).
start_(span("enrolled",108,115),span(20150829,172,187)).
end_(span("enrolled",108,115),span(20190530,192,206)).
