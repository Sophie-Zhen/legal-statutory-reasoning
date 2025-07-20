% Stage 2 Generated Facts
% Case: s3306_c_6_neg
% Text: Alice was paid $73200 in 2017 as an employee of Nando's Chicken in Arlington, Virginia, USA.
% Question: Section 3306(c)(6) applies to Alice's employment situation in 2017. Contradiction

:- ['statutes/prolog/init'].
payment_(span("paid",10,13)).
patient_(span("paid",10,13),span("Alice",0,4)).
amount_(span("paid",10,13),span(73200,15,20)).
start_(span("paid",10,13),span(2017,25,28)).
employment_(span("employee",36,43)).
agent_(span("employee",36,43),span("Alice",0,4)).
patient_(span("employee",36,43),span("Nando's Chicken",48,62)).
start_(span("employee",36,43),span(2017,25,28)).
location_(span("employee",36,43),span("Arlington, Virginia, USA",67,91)).
