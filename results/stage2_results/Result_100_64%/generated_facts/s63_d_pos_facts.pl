% Stage 2 Generated Facts
% Case: s63_d_pos
% Text: In 2017, Alice was paid $33200. She is allowed a deduction of $1200 for the year 2017 for donating cash to charity.
% Question: Alice's deduction for 2017 falls under section 63(d). Entailment

:- ['statutes/prolog/init'].
income_(span("paid",20,23)).
patient_(span("paid",20,23),span("Alice",10,14)).
amount_(span("paid",20,23),span(33200,25,30)).
start_(span("paid",20,23),span(2017,3,6)).
deduction_(span("deduction",49,57)).
agent_(span("deduction",49,57),span("She",33,35)).
amount_(span("deduction",49,57),span(1200,62,66)).
start_(span("deduction",49,57),span(2017,81,84)).
donation_(span("donating",90,97)).
agent_(span("donating",90,97),span("She",33,35)).
object_(span("donating",90,97),span("cash",99,102)).
recipient_(span("donating",90,97),span("charity",107,113)).
start_(span("donating",90,97),span(2017,81,84)).
