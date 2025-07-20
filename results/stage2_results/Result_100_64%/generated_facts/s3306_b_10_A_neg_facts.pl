% Stage 2 Generated Facts
% Case: s3306_b_10_A_neg
% Text: Alice has employed Bob from Jan 1st, 2011 to Oct 10, 2019. On Oct 10, 2019 Bob retired because he reached age 65. Alice paid Bob $12980 as a retirement bonus.
% Question: Section 3306(b)(10)(A) applies to the payment of $12980 that Alice made in 2019. Contradiction

:- ['statutes/prolog/init'].
employment_(span("employed",10,17)).
agent_(span("employed",10,17),span("Alice",0,4)).
patient_(span("employed",10,17),span("Bob",19,21)).
start_(span("employed",10,17),span(20110101,28,41)).
end_(span("employed",10,17),span(20191010,46,58)).
retirement_(span("retired",81,87)).
agent_(span("retired",81,87),span("Bob",77,79)).
start_(span("retired",81,87),span(20191010,64,75)).
age_(span("age 65",106,111)).
agent_(span("age 65",106,111),span("Bob",77,79)).
amount_(span("age 65",106,111),span(65,110,111)).
start_(span("age 65",106,111),span(20191010,64,75)).
payment_(span("paid",120,123)).
agent_(span("paid",120,123),span("Alice",114,118)).
patient_(span("paid",120,123),span("Bob",125,127)).
amount_(span("paid",120,123),span(12980,129,134)).
purpose_(span("paid",120,123),span("retirement bonus",141,156)).
start_(span("paid",120,123),span(20191010,64,75)).
