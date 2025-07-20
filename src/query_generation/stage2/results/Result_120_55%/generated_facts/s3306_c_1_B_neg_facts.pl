% Stage 2 Generated Facts
% Case: s3306_c_1_B_neg
% Text: Alice has paid $3200 to Bob for agricultural labor done from Feb 1st, 2017 to Sep 2nd, 2017, in Stanley, Wisconsin, USA. Alice is an American citizen, and Bob is a Mexican citizen who was admitted to the USA to perform agricultural labor pursuant to sections 214(c) and 101(a)(15)(H) of the Immigration and Nationality Act.
% Question: Section 3306(c)(1)(B) applies to Alice employing Bob for the year 2017. Contradiction

:- discontiguous agent_/2.
:- discontiguous patient_/2.
:- discontiguous purpose_/2.
:- discontiguous citizen_/1.
:- discontiguous nationality_/2.
:- ['statutes/prolog/init'].
payment_(span("paid",10,13)).
agent_(span("paid",10,13),span("Alice",0,4)).
patient_(span("paid",10,13),span("Bob",22,24)).
amount_(span("paid",10,13),span(3200,15,19)).
purpose_(span("paid",10,13),span("agricultural labor",30,48)).
agricultural_labor_(span("agricultural labor",30,48)).
agent_(span("agricultural labor",30,48),span("Bob",22,24)).
patient_(span("agricultural labor",30,48),span("Alice",0,4)).
start_(span("agricultural labor",30,48),span(20170201,55,67)).
end_(span("agricultural labor",30,48),span(20170902,72,85)).
location_(span("agricultural labor",30,48),span("Stanley, Wisconsin, USA",91,114)).
citizen_(span("citizen",131,137)).
agent_(span("citizen",131,137),span("Alice",117,121)).
nationality_(span("citizen",131,137),span("American",122,129)).
citizen_(span("citizen",156,162)).
agent_(span("citizen",156,162),span("Bob",143,145)).
nationality_(span("citizen",156,162),span("Mexican",148,154)).
admission_(span("admitted",172,179)).
agent_(span("admitted",172,179),span("Bob",143,145)).
destination_(span("admitted",172,179),span("USA",188,190)).
purpose_(span("admitted",172,179),span("to perform agricultural labor",192,220)).
authority_(span("admitted",172,179),span("sections 214(c) and 101(a)(15)(H) of the Immigration and Nationality Act",234,318)).
