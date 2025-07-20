% Stage 2 Generated Facts
% Case: s3306_c_1_A_i_pos
% Text: Alice has paid $23200 in remuneration to Bob for agricultural labor done from Feb 1st, 2017 to Sep 2nd, 2017, in Caracas, Venezuela. Alice is an American employer.
% Question: Section 3306(c)(1)(A)(i) applies to Alice employing Bob for the year 2017. Entailment

:- ['statutes/prolog/init'].
payment_(span("paid",10,13)).
agent_(span("paid",10,13),span("Alice",0,4)).
amount_(span("paid",10,13),span(23200,15,20)).
theme_(span("paid",10,13),span("remuneration",25,36)).
patient_(span("paid",10,13),span("Bob",39,41)).
remuneration_(span("remuneration",25,36)).
theme_(span("remuneration",25,36),span("agricultural labor",47,64)).
agricultural_labor_(span("agricultural labor",47,64)).
agent_(span("agricultural labor",47,64),span("Bob",39,41)).
start_(span("agricultural labor",47,64),span(20170201,71,84)).
end_(span("agricultural labor",47,64),span(20170902,89,102)).
location_(span("agricultural labor",47,64),span("Caracas, Venezuela",108,126)).
american_employer_(span("American employer",135,151)).
agent_(span("American employer",135,151),span("Alice",129,133)).
