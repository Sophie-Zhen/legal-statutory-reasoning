% Stage 2 Generated Facts
% Case: s2_a_1_B_pos
% Text: Alice and Bob got married on Feb 3rd, 1992. Alice and Bob have a child, Charlie, born October 9th, 2000. Alice died on July 9th, 2014. From 2004 to 2017, Bob furnished the costs of maintaining the home where he and Charlie lived during that time. From 2014 to 2017, Bob was entitled to a deduction for Charlie under section 151. Bob's income in 2016 was $553252.
% Question: Section 2(a)(1)(B) applies to Bob in 2016. Entailment

:- discontiguous s63/3.
:- discontiguous s152_a/3.
:- ['statutes/prolog/init'].
marriage_(span("married",18,24)).
agent_(span("married",18,24),span("Alice",0,4)).
agent_(span("married",18,24),span("Bob",10,12)).
start_(span("married",18,24),span(19920203,29,41)).
child_(span("child",65,69)).
patient_(span("child",65,69),span("Alice",44,48)).
patient_(span("child",65,69),span("Bob",54,56)).
agent_(span("child",65,69),span("Charlie",72,78)).
birth_(span("born",81,84)).
agent_(span("born",81,84),span("Charlie",72,78)).
start_(span("born",81,84),span(20001009,86,103)).
death_(span("died",112,115)).
agent_(span("died",112,115),span("Alice",106,110)).
start_(span("died",112,115),span(20140709,120,134)).
payment_(span("furnished the costs of maintaining the home",160,201)).
agent_(span("furnished the costs of maintaining the home",160,201),span("Bob",156,158)).
start_(span("furnished the costs of maintaining the home",160,201),span(2004,142,145)).
end_(span("furnished the costs of maintaining the home",160,201),span(2017,150,153)).
residence_(span("lived",225,229)).
agent_(span("lived",225,229),span("he",210,211)).
agent_(span("lived",225,229),span("Charlie",217,223)).
start_(span("lived",225,229),span(2004,142,145)).
end_(span("lived",225,229),span(2017,150,153)).
s152_a("Charlie","Bob",2014).
s152_a("Charlie","Bob",2015).
s152_a("Charlie","Bob",2016).
s152_a("Charlie","Bob",2017).
income_(span("income",343,348)).
agent_(span("income",343,348),span("Bob",338,340)).
start_(span("income",343,348),span(2016,353,356)).
amount_(span("income",343,348),span(553252,362,368)).
s63("Bob",2016,553252).
