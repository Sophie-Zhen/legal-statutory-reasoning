% Stage 2 Generated Facts
% Case: s3306_a_3_neg
% Text: Alice has paid $3200 in cash to Bob for agricultural labor done from Feb 1st, 2017 to Sep 2nd, 2017. Bob has paid $4200 in cash to Alice for domestic service done from Apr 1st, 2017 to Sep 1st, 2018 in his home.
% Question: Section 3306(a)(3) applies to Alice for the year 2017. Contradiction

:- ['statutes/prolog/init'].
payment_(span("paid",10,13)).
agent_(span("paid",10,13),span("Alice",0,4)).
amount_(span("paid",10,13),span(3200,15,19)).
medium_(span("paid",10,13),span("cash",24,27)).
patient_(span("paid",10,13),span("Bob",32,34)).
theme_(span("paid",10,13),span("agricultural labor",40,57)).
start_(span("paid",10,13),span(20170201,64,77)).
end_(span("paid",10,13),span(20170902,82,95)).
payment_(span("paid",104,107)).
agent_(span("paid",104,107),span("Bob",98,100)).
amount_(span("paid",104,107),span(4200,109,113)).
medium_(span("paid",104,107),span("cash",118,121)).
patient_(span("paid",104,107),span("Alice",126,130)).
theme_(span("paid",104,107),span("domestic service",136,151)).
start_(span("paid",104,107),span(20170401,158,171)).
end_(span("paid",104,107),span(20180901,176,189)).
residence_(span("home",200,203)).
agent_(span("home",200,203),span("Bob",98,100)).
agent_(span("home",200,203),span("Alice",126,130)).
start_(span("home",200,203),span(20170401,158,171)).
end_(span("home",200,203),span(20180901,176,189)).
