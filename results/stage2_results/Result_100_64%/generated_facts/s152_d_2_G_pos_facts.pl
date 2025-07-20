% Stage 2 Generated Facts
% Case: s152_d_2_G_pos
% Text: Charlie is Bob's father since April 15th, 2014. Alice married Bob on October 12th, 1992.
% Question: Alice bears a relationship to Charlie under section 152(d)(2)(G) for the year 2018. Entailment

:- ['statutes/prolog/init'].
father_(span("father",18,23)).
agent_(span("father",18,23),span("Charlie",0,6)).
patient_(span("father",18,23),span("Bob",11,13)).
start_(span("father",18,23),span(20140415,31,46)).
marriage_(span("married",55,61)).
agent_(span("married",55,61),span("Alice",49,53)).
agent_(span("married",55,61),span("Bob",63,65)).
start_(span("married",55,61),span(19921012,70,87)).
