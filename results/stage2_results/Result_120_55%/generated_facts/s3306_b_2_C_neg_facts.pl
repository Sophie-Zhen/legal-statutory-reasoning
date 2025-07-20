% Stage 2 Generated Facts
% Case: s3306_b_2_C_neg
% Text: Alice has paid $45252 to Bob for work done in the year 2017. In 2017, Alice has also paid $9832 into a retirement fund for Bob, and paid $5322 into life insurance for Charlie, who is Alice's father and has retired in 2016.
% Question: Section 3306(b)(2)(C) applies to the payment Alice made to the retirement fund for the year 2017. Contradiction

:- ['statutes/prolog/init'].
payment_(span("paid",10,13)).
agent_(span("paid",10,13),span("Alice",0,4)).
patient_(span("paid",10,13),span("Bob",22,24)).
amount_(span("paid",10,13),span(45252,15,20)).
start_(span("paid",10,13),span(2017,52,55)).
payment_(span("paid",78,81)).
agent_(span("paid",78,81),span("Alice",67,71)).
patient_(span("paid",78,81),span("Bob",116,118)).
amount_(span("paid",78,81),span(9832,83,87)).
start_(span("paid",78,81),span(2017,59,62)).
payment_(span("paid",125,128)).
agent_(span("paid",125,128),span("Alice",67,71)).
patient_(span("paid",125,128),span("Charlie",160,166)).
amount_(span("paid",125,128),span(5322,130,134)).
start_(span("paid",125,128),span(2017,59,62)).
father_(span("father",182,187)).
agent_(span("father",182,187),span("Charlie",160,166)).
patient_(span("father",182,187),span("Alice",175,179)).
retirement_(span("retired",197,203)).
agent_(span("retired",197,203),span("Charlie",160,166)).
start_(span("retired",197,203),span(2016,208,211)).
