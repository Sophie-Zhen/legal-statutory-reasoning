% Stage 2 Generated Facts
% Case: s2_b_1_A_i_II_neg
% Text: Alice and Bob got married on Feb 3rd, 1992. Alice and Bob have a child, Charlie, born October 9th, 2000. Alice died on July 9th, 2014. From 2004 to 2019, Bob furnished the costs of maintaining the home where he and Charlie lived during that time. Charlie married Dan on Feb 14th, 2018.
% Question: Section 2(b)(1)(A)(i)(II) applies to Bob with Charlie as the qualifying child in 2018. Contradiction

:- ['statutes/prolog/init'].
marriage_(span("married",18,24)).
agent_(span("married",18,24),span("Alice",0,4)).
agent_(span("married",18,24),span("Bob",10,12)).
start_(span("married",18,24),span(19920203,29,42)).
child_(span("child",65,69)).
patient_(span("child",65,69),span("Alice",47,51)).
patient_(span("child",65,69),span("Bob",57,59)).
agent_(span("child",65,69),span("Charlie",72,78)).
birth_(span("born",81,84)).
agent_(span("born",81,84),span("Charlie",72,78)).
start_(span("born",81,84),span(20001009,86,104)).
death_(span("died",114,117)).
agent_(span("died",114,117),span("Alice",109,113)).
start_(span("died",114,117),span(20140709,122,137)).
payment_(span("furnished",162,170)).
agent_(span("furnished",162,170),span("Bob",157,159)).
cost_(span("furnished",162,170),span("costs of maintaining the home",176,206)).
start_(span("furnished",162,170),span(20040101,146,149)).
end_(span("furnished",162,170),span(20191231,154,157)).
residence_(span("lived",230,234)).
agent_(span("lived",230,234),span("Bob",157,159)).
agent_(span("lived",230,234),span("Charlie",225,231)).
start_(span("lived",230,234),span(20040101,146,149)).
end_(span("lived",230,234),span(20191231,154,157)).
marriage_(span("married",260,266)).
agent_(span("married",260,266),span("Charlie",252,258)).
agent_(span("married",260,266),span("Dan",268,270)).
start_(span("married",260,266),span(20180214,275,289)).
