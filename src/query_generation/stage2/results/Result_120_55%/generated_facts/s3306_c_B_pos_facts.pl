% Stage 2 Generated Facts
% Case: s3306_c_B_pos
% Text: Alice has paid $3200 to Bob for work done from Feb 1st, 2017 to Sep 2nd, 2017, in Caracas, Venezuela. Bob is an American citizen and Alice is an American employer.
% Question: Section 3306(c)(B) applies to Alice employing Bob for the year 2017. Entailment

:- discontiguous s3306_c_B_applies/3.
:- discontiguous agent_/2.
:- discontiguous location_/2.
:- ['statutes/prolog/init'].
s3306_c_B_applies("Alice","Bob",2017).
payment_(span("paid",10,13)).
agent_(span("paid",10,13),span("Alice",0,4)).
patient_(span("paid",10,13),span("Bob",24,26)).
amount_(span("paid",10,13),span(3200,15,19)).
start_(span("paid",10,13),span(20170201,44,56)).
end_(span("paid",10,13),span(20170902,61,73)).
location_(span("paid",10,13),span("Caracas, Venezuela",79,97)).
citizen_(span("citizen",117,123)).
agent_(span("citizen",117,123),span("Bob",101,103)).
location_(span("citizen",117,123),span("American",108,115)).
employer_(span("employer",148,155)).
agent_(span("employer",148,155),span("Alice",127,131)).
location_(span("employer",148,155),span("American",139,146)).
