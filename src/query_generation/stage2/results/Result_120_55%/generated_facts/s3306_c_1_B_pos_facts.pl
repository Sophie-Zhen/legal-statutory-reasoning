% Stage 2 Generated Facts
% Case: s3306_c_1_B_pos
% Text: Alice has paid $3200 to Bob for agricultural labor done from Feb 1st, 2017 to Sep 2nd, 2017, in Caracas, Venezuela. Bob is an American citizen. Alice is an American employer.
% Question: Section 3306(c)(1)(B) applies to Alice employing Bob for the year 2017. Entailment

:- ['statutes/prolog/init'].
payment_(span("paid",10,13)).
agent_(span("paid",10,13),span("Alice",0,4)).
patient_(span("paid",10,13),span("Bob",24,26)).
amount_(span("paid",10,13),span(3200,16,19)).
start_(span("paid",10,13),span(20170201,62,75)).
end_(span("paid",10,13),span(20170902,80,93)).
agricultural_labor_(span("agricultural labor",32,51)).
agent_(span("agricultural labor",32,51),span("Bob",24,26)).
patient_(span("agricultural labor",32,51),span("Alice",0,4)).
start_(span("agricultural labor",32,51),span(20170201,62,75)).
end_(span("agricultural labor",32,51),span(20170902,80,93)).
location_(span("agricultural labor",32,51),span("Caracas",99,105)).
location_(span("agricultural labor",32,51),span("Venezuela",108,116)).
american_citizen_(span("American citizen",126,141)).
agent_(span("American citizen",126,141),span("Bob",119,121)).
american_employer_(span("American employer",153,169)).
agent_(span("American employer",153,169),span("Alice",144,148)).
