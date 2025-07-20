% Stage 2 Generated Facts
% Case: s3306_c_1_A_i_neg
% Text: Alice has paid $2300 to Bob for agricultural labor done from Feb 1st, 2017 to Sep 2nd, 2017, in Caracas, Venezuela. Alice and Bob are both American citizens.
% Question: Section 3306(c)(1)(A)(i) applies to Alice employing Bob for the year 2017. Contradiction

:- ['statutes/prolog/init'].
payment_(span("paid",10,13)).
agent_(span("paid",10,13),span("Alice",0,4)).
patient_(span("paid",10,13),span("Bob",22,24)).
amount_(span("paid",10,13),span(2300,15,19)).
agricultural_labor_(span("agricultural labor",29,46)).
agent_(span("agricultural labor",29,46),span("Bob",22,24)).
patient_(span("agricultural labor",29,46),span("Alice",0,4)).
start_(span("agricultural labor",29,46),span(20170201,53,66)).
end_(span("agricultural labor",29,46),span(20170902,71,84)).
location_(span("agricultural labor",29,46),span("Caracas, Venezuela",90,108)).
american_citizen_(span("American citizens",131,147)).
agent_(span("American citizens",131,147),span("Alice",113,117)).
agent_(span("American citizens",131,147),span("Bob",123,125)).
