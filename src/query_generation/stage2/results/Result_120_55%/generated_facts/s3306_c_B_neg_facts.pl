% Stage 2 Generated Facts
% Case: s3306_c_B_neg
% Text: Alice has paid $3200 to Bob for work done from Feb 1st, 2017 to Sep 2nd, 2017, in Caracas, Venezuela. Alice is a citizen of Venezuela, and Bob is an American citizen.
% Question: Section 3306(c)(B) applies to Alice employing Bob for the year 2017. Contradiction

:- discontiguous agent_/2.
:- discontiguous patient_/2.
:- discontiguous location_/2.
:- discontiguous citizen_/1.
:- ['statutes/prolog/init'].
payment_(span("paid",10,13)).
agent_(span("paid",10,13),span("Alice",0,4)).
patient_(span("paid",10,13),span("Bob",24,26)).
amount_(span("paid",10,13),span(3200,15,19)).
purpose_(span("paid",10,13),span("work",32,35)).
employment_(span("work",32,35)).
agent_(span("work",32,35),span("Bob",24,26)).
patient_(span("work",32,35),span("Alice",0,4)).
start_(span("work",32,35),span(20170201,47,60)).
end_(span("work",32,35),span(20170902,65,78)).
location_(span("work",32,35),span("Caracas",84,90)).
location_(span("work",32,35),span("Venezuela",93,101)).
citizen_(span("citizen",115,121)).
agent_(span("citizen",115,121),span("Alice",104,108)).
patient_(span("citizen",115,121),span("Venezuela",126,134)).
citizen_(span("citizen",160,166)).
agent_(span("citizen",160,166),span("Bob",141,143)).
patient_(span("citizen",160,166),span("American",151,158)).
