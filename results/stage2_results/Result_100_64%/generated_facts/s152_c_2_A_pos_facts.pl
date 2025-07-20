% Stage 2 Generated Facts
% Case: s152_c_2_A_pos
% Text: Alice has a son, Bob, who was born January 31st, 2014.
% Question: Bob bears a relationship to Alice under section 152(c)(2)(A). Entailment

:- ['statutes/prolog/init'].
son_(span("son",12,14)).
patient_(span("son",12,14),span("Alice",0,4)).
agent_(span("son",12,14),span("Bob",17,19)).
start_(span("son",12,14),span(20140131,34,51)).
birth_(span("born",29,32)).
agent_(span("born",29,32),span("Bob",17,19)).
start_(span("born",29,32),span(20140131,34,51)).
