% Stage 2 Generated Facts
% Case: s3306_c_11_pos
% Text: Alice was paid $73200 in 2017 as an employee of the Canadian Government, in Toronto, Ontario, Canada.
% Question: Section 3306(c)(11) applies to Alice's employment situation in 2017. Entailment

:- discontiguous s3306_c_11_applies/2.
:- ['statutes/prolog/init'].
payment_(span("paid",9,12)).
agent_(span("paid",9,12),span("Canadian Government",51,69)).
patient_(span("paid",9,12),span("Alice",0,4)).
amount_(span("paid",9,12),span(73200,14,19)).
start_(span("paid",9,12),span(2017,24,27)).
employment_(span("employee",35,42)).
agent_(span("employee",35,42),span("Alice",0,4)).
patient_(span("employee",35,42),span("Canadian Government",51,69)).
start_(span("employee",35,42),span(2017,24,27)).
location_(span("employee",35,42),span("Toronto, Ontario, Canada",75,99)).
s3306_c_11_applies("Alice",2017).
