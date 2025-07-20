% Stage 2 Generated Facts
% Case: s3306_a_1_B_pos
% Text: Alice has employed Bob on various occasions during the year 2017: - Jan 24 - Feb 4 - Mar 3 - Mar 18 - Apr 1 - May 9 - Oct 14 - Oct 25 - Nov 8 - Nov 22 - Dec 1 - Dec 2
% Question: Section 3306(a)(1)(B) applies to Alice for the year 2017. Entailment

:- ['statutes/prolog/init'].
employment_(span("employed",10,17)).
agent_(span("employed",10,17),span("Alice",0,4)).
patient_(span("employed",10,17),span("Bob",19,21)).
start_(span("employed",10,17),span(20170124,60,65)).
start_(span("employed",10,17),span(20170204,69,73)).
start_(span("employed",10,17),span(20170303,77,81)).
start_(span("employed",10,17),span(20170318,85,90)).
start_(span("employed",10,17),span(20170401,94,98)).
start_(span("employed",10,17),span(20170509,102,106)).
start_(span("employed",10,17),span(20171014,110,115)).
start_(span("employed",10,17),span(20171025,119,124)).
start_(span("employed",10,17),span(20171108,128,132)).
start_(span("employed",10,17),span(20171122,136,141)).
start_(span("employed",10,17),span(20171201,145,149)).
start_(span("employed",10,17),span(20171202,153,157)).
