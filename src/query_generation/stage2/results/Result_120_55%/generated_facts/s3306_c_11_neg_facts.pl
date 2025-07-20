% Stage 2 Generated Facts
% Case: s3306_c_11_neg
% Text: Alice was paid $73200 in 2017 as an employee of the State of Maryland in Baltimore, Maryland, USA.
% Question: Section 3306(c)(11) applies to Alice's employment situation in 2017. Contradiction

:- ['statutes/prolog/init'].
payment_(span("paid",9,12)).
patient_(span("paid",9,12),span("Alice",0,4)).
amount_(span("paid",9,12),span(73200,14,19)).
start_(span("paid",9,12),span(2017,24,27)).
employment_(span("employee",35,42)).
agent_(span("employee",35,42),span("Alice",0,4)).
patient_(span("employee",35,42),span("the State of Maryland",47,67)).
start_(span("employee",35,42),span(2017,24,27)).
location_(span("employee",35,42),span("Baltimore, Maryland, USA",72,96)).
