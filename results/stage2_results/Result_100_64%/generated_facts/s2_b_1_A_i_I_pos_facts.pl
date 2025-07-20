% Stage 2 Generated Facts
% Case: s2_b_1_A_i_I_pos
% Text: Alice and Bob got married on Feb 3rd, 1992. Alice and Bob have a child, Charlie, born October 9th, 2000. Alice died on July 9th, 2014. From 2004 to 2019, Bob furnished the costs of maintaining the home where he and Charlie lived during that time. Charlie married Dan on Feb 14th, 2017.
% Question: Section 2(b)(1)(A)(i)(I) applies to Charlie in 2017. Entailment

:- ['statutes/prolog/init'].
marriage_(span("married",18,24)).
agent_(span("married",18,24),span("Alice",0,4)).
agent_(span("married",18,24),span("Bob",10,12)).
start_(span("married",18,24),span(19920203,29,42)).
child_(span("child",65,69)).
patient_(span("child",65,69),span("Alice",45,49)).
patient_(span("child",65,69),span("Bob",55,57)).
agent_(span("child",65,69),span("Charlie",72,78)).
birth_(span("born",81,84)).
agent_(span("born",81,84),span("Charlie",72,78)).
start_(span("born",81,84),span(20001009,86,104)).
death_(span("died",114,117)).
agent_(span("died",114,117),span("Alice",108,112)).
start_(span("died",114,117),span(20140709,122,137)).
payment_(span("furnished the costs of maintaining the home",163,208)).
agent_(span("furnished the costs of maintaining the home",163,208),span("Bob",159,161)).
start_(span("furnished the costs of maintaining the home",163,208),span(20040101,145,148)).
end_(span("furnished the costs of maintaining the home",163,208),span(20191231,153,156)).
residence_(span("lived",230,234)).
agent_(span("lived",230,234),span("Bob",159,161)).
agent_(span("lived",230,234),span("Charlie",222,228)).
start_(span("lived",230,234),span(20040101,145,148)).
end_(span("lived",230,234),span(20191231,153,156)).
marriage_(span("married",270,276)).
agent_(span("married",270,276),span("Charlie",262,268)).
agent_(span("married",270,276),span("Dan",278,280)).
start_(span("married",270,276),span(20170214,285,300)).
