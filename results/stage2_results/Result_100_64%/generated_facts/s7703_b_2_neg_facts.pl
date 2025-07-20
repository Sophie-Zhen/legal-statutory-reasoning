% Stage 2 Generated Facts
% Case: s7703_b_2_neg
% Text: Alice and Bob got married on April 5th, 2012. Alice and Bob have a son, Charlie, who was born on September 16th, 2017. Alice and Charlie live in a home for which Alice furnished 40% of the maintenance costs, since September 16th, 2017. Alice is entitled to a deduction for Charlie under section 151(c) for the years 2017 to 2019.
% Question: Section 7703(b)(2) applies to Alice maintaining her home for the year 2018. Contradiction

:- discontiguous s151_c/4.
:- ['statutes/prolog/init'].
marriage_(span("married",18,24)).
agent_(span("married",18,24),span("Alice",0,4)).
agent_(span("married",18,24),span("Bob",10,12)).
start_(span("married",18,24),span(20120405,29,44)).
son_(span("son",68,70)).
patient_(span("son",68,70),span("Alice",47,51)).
patient_(span("son",68,70),span("Bob",57,59)).
agent_(span("son",68,70),span("Charlie",73,79)).
birth_(span("born",91,94)).
agent_(span("born",91,94),span("Charlie",73,79)).
start_(span("born",91,94),span(20170916,99,117)).
residence_(span("live in a home",137,150)).
agent_(span("live in a home",137,150),span("Alice",119,123)).
agent_(span("live in a home",137,150),span("Charlie",129,135)).
start_(span("live in a home",137,150),span(20170916,215,233)).
payment_(span("furnished",169,177)).
agent_(span("furnished",169,177),span("Alice",163,167)).
amount_(span("furnished",169,177),span(40,179,181)).
patient_(span("furnished",169,177),span("maintenance costs",190,206)).
start_(span("furnished",169,177),span(20170916,215,233)).
s151_c("Alice","Charlie",_,2017).
s151_c("Alice","Charlie",_,2018).
s151_c("Alice","Charlie",_,2019).
