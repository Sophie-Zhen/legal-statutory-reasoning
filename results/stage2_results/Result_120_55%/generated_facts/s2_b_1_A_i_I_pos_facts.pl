% Stage 2 Generated Facts
% Case: s2_b_1_A_i_I_pos
% Text: Alice and Bob got married on Feb 3rd, 1992. Alice and Bob have a child, Charlie, born October 9th, 2000. Alice died on July 9th, 2014. From 2004 to 2019, Bob furnished the costs of maintaining the home where he and Charlie lived during that time. Charlie married Dan on Feb 14th, 2017.
% Question: Section 2(b)(1)(A)(i)(I) applies to Charlie in 2017. Entailment

:- ['statutes/prolog/init'].
marriage_(span("married",18,24)).
agent_(span("married",18,24),span("Alice",0,4)).
agent_(span("married",18,24),span("Bob",10,12)).
start_(span("married",18,24),span(19920203,29,42)).
child_(span("child",66,70)).
patient_(span("child",66,70),span("Alice",45,49)).
patient_(span("child",66,70),span("Bob",55,57)).
agent_(span("child",66,70),span("Charlie",73,79)).
mother_(span("child",66,70)).
patient_(span("child",66,70),span("Charlie",73,79)).
agent_(span("child",66,70),span("Alice",45,49)).
father_(span("child",66,70)).
patient_(span("child",66,70),span("Charlie",73,79)).
agent_(span("child",66,70),span("Bob",55,57)).
birth_(span("born",82,85)).
agent_(span("born",82,85),span("Charlie",73,79)).
start_(span("born",82,85),span(20001009,87,105)).
death_(span("died",114,117)).
agent_(span("died",114,117),span("Alice",108,112)).
start_(span("died",114,117),span(20140709,122,136)).
payment_(span("furnished",162,170)).
agent_(span("furnished",162,170),span("Bob",158,160)).
start_(span("furnished",162,170),span(20040101,144,147)).
end_(span("furnished",162,170),span(20191231,152,155)).
residence_(span("lived",222,226)).
agent_(span("lived",222,226),span("Bob",158,160)).
agent_(span("lived",222,226),span("Charlie",214,220)).
start_(span("lived",222,226),span(20040101,144,147)).
end_(span("lived",222,226),span(20191231,152,155)).
marriage_(span("married",259,265)).
agent_(span("married",259,265),span("Charlie",251,257)).
agent_(span("married",259,265),span("Dan",267,269)).
start_(span("married",259,265),span(20170214,274,289)).
