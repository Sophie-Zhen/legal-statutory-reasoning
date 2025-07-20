% Stage 2 Generated Facts
% Case: tax_case_49
% Text: Bob is Alice and Charlie's father. Bob had no income in 2015. Alice's gross income in 2015 is $264215. Alice takes the standard deduction.
% Question: How much tax does Alice have to pay in 2015? $82819

:- ['statutes/prolog/init'].
father_(span("father",27,32)).
agent_(span("father",27,32),span("Bob",0,2)).
patient_(span("father",27,32),span("Alice",7,11)).
patient_(span("father",27,32),span("Charlie",17,23)).
income_(span("income",46,51)).
agent_(span("income",46,51),span("Bob",35,37)).
amount_(span("income",46,51),0).
start_(span("income",46,51),span(2015,56,59)).
income_(span("income",76,81)).
agent_(span("income",76,81),span("Alice",62,66)).
amount_(span("income",76,81),264215).
start_(span("income",76,81),span(2015,86,89)).
