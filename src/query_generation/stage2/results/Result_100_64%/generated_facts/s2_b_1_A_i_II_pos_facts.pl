% Stage 2 Generated Facts
% Case: s2_b_1_A_i_II_pos
% Text: Alice and Bob got married on Feb 3rd, 1992. Alice and Bob have a child, Charlie, born October 9th, 2000. Alice died on July 9th, 2014. From 2004 to 2019, Bob furnished the costs of maintaining the home where he and Charlie lived during that time. Charlie married Dan on Feb 14th, 2018. Section 152(b)(2) applies to Charlie as the dependent and Bob as the taxpayer for 2018.
% Question: Section 2(b)(1)(A)(i)(II) applies to Bob with Charlie as the qualifying child in 2018. Entailment

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
death_(span("died",112,115)).
agent_(span("died",112,115),span("Alice",106,110)).
start_(span("died",112,115),span(20140709,120,134)).
payment_(span("furnished the costs",159,177)).
agent_(span("furnished the costs",159,177),span("Bob",155,157)).
start_(span("furnished the costs",159,177),span(2004,141,144)).
end_(span("furnished the costs",159,177),span(2019,149,152)).
residence_(span("lived",223,227)).
agent_(span("lived",223,227),span("Bob",155,157)).
agent_(span("lived",223,227),span("Charlie",215,221)).
location_(span("lived",223,227),span("home",198,201)).
start_(span("lived",223,227),span(2004,141,144)).
end_(span("lived",223,227),span(2019,149,152)).
marriage_(span("married",258,264)).
agent_(span("married",258,264),span("Charlie",250,256)).
agent_(span("married",258,264),span("Dan",266,268)).
start_(span("married",258,264),span(20180214,273,287)).
s152_b_2_applies("Bob","Charlie",2018).
