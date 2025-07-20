% Stage 2 Generated Facts
% Case: s2_b_1_A_i_neg
% Text: Alice and Bob got married on Feb 3rd, 1992. Alice and Bob have a child, Charlie, born October 9th, 2000. Alice died on July 9th, 2014. From 2004 to 2019, Bob furnished the costs of maintaining the home where he and Charlie lived during that time. Charlie married Dan on Feb 14th, 2018. Section 152(b)(2) applies to Bob as the dependent and Charlie as the taxpayer for 2018.
% Question: Section 2(b)(1)(A)(i) applies to Bob in 2018. Contradiction

:- discontiguous s152_b_2_applies/3.
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
death_(span("died",117,120)).
agent_(span("died",117,120),span("Alice",111,115)).
start_(span("died",117,120),span(20140709,125,141)).
furnishing_(span("furnished",167,175)).
agent_(span("furnished",167,175),span("Bob",163,165)).
patient_(span("furnished",167,175),span("home",208,211)).
start_(span("furnished",167,175),span(2004,149,152)).
end_(span("furnished",167,175),span(2019,157,160)).
residence_(span("lived",233,237)).
agent_(span("lived",233,237),span("he",218,219)).
agent_(span("lived",233,237),span("Charlie",225,231)).
location_(span("lived",233,237),span("home",208,211)).
start_(span("lived",233,237),span(2004,149,152)).
end_(span("lived",233,237),span(2019,157,160)).
marriage_(span("married",274,280)).
agent_(span("married",274,280),span("Charlie",266,272)).
agent_(span("married",274,280),span("Dan",282,284)).
start_(span("married",274,280),span(20180214,289,304)).
s152_b_2_applies("Charlie","Bob",2018).
