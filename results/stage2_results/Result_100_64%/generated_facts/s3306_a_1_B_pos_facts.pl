% Stage 2 Generated Facts
% Case: s3306_a_1_B_pos
% Text: Alice has employed Bob on various occasions during the year 2017: - Jan 24 - Feb 4 - Mar 3 - Mar 18 - Apr 1 - May 9 - Oct 14 - Oct 25 - Nov 8 - Nov 22 - Dec 1 - Dec 2
% Question: Section 3306(a)(1)(B) applies to Alice for the year 2017. Entailment

:- discontiguous s3306_a_1_B_applies/2.
:- ['statutes/prolog/init'].
s3306_a_1_B_applies("Alice",2017).
employment_(span("employed",10,17)).
agent_(span("employed",10,17),span("Alice",0,4)).
patient_(span("employed",10,17),span("Bob",19,21)).
start_(span("employed",10,17),span(20170124,61,66)).
start_(span("employed",10,17),span(20170204,69,73)).
start_(span("employed",10,17),span(20170303,76,80)).
start_(span("employed",10,17),span(20170318,83,88)).
start_(span("employed",10,17),span(20170401,91,95)).
start_(span("employed",10,17),span(20170509,98,102)).
start_(span("employed",10,17),span(20171014,105,110)).
start_(span("employed",10,17),span(20171025,113,118)).
start_(span("employed",10,17),span(20171108,121,125)).
start_(span("employed",10,17),span(20171122,128,133)).
start_(span("employed",10,17),span(20171201,136,140)).
start_(span("employed",10,17),span(20171202,143,147)).
