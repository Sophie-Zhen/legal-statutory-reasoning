% Stage 2 Generated Facts
% Case: s152_d_2_G_pos
% Text: Charlie is Bob's father since April 15th, 2014. Alice married Bob on October 12th, 1992.
% Question: Alice bears a relationship to Charlie under section 152(d)(2)(G) for the year 2018. Entailment

:- ['statutes/prolog/init'].
father_(span("father",16,21)).
agent_(span("father",16,21),span("Charlie",0,6)).
patient_(span("father",16,21),span("Bob",11,13)).
start_(span("father",16,21),span(20140415,29,45)).
marriage_(span("married",54,60)).
agent_(span("married",54,60),span("Alice",48,52)).
agent_(span("married",54,60),span("Bob",62,64)).
start_(span("married",54,60),span(19921012,69,87)).
