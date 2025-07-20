% Stage 2 Generated Facts
% Case: s2_b_1_A_i_pos
% Text: Alice and Bob got married on Feb 3rd, 1992. Alice and Bob have a child, Charlie, born October 9th, 2000. Alice died on July 9th, 2014. From 2004 to 2019, Bob furnished the costs of maintaining the home where he and Charlie lived during that time.
% Question: Section 2(b)(1)(A)(i) applies to Charlie in 2018. Entailment

:- discontiguous agent_/2.
:- discontiguous patient_/2.
:- discontiguous start_/2.
:- discontiguous end_/2.
:- ['statutes/prolog/init'].
marriage_(span("married",18,24)).
agent_(span("married",18,24),span("Alice",0,4)).
agent_(span("married",18,24),span("Bob",10,12)).
start_(span("married",18,24),span(19920203,29,41)).
child_(span("child",66,70)).
patient_(span("child",66,70),span("Alice",44,48)).
patient_(span("child",66,70),span("Bob",54,56)).
agent_(span("child",66,70),span("Charlie",73,79)).
birth_(span("born",82,85)).
agent_(span("born",82,85),span("Charlie",73,79)).
start_(span("born",82,85),span(20001009,87,104)).
death_(span("died",113,116)).
agent_(span("died",113,116),span("Alice",107,111)).
start_(span("died",113,116),span(20140709,118,132)).
furnish_(span("furnished",165,173)).
agent_(span("furnished",165,173),span("Bob",162,164)).
start_(span("furnished",165,173),span(2004,147,150)).
end_(span("furnished",165,173),span(2019,155,158)).
residence_(span("lived",230,234)).
agent_(span("lived",230,234),span("he",218,219)).
agent_(span("lived",230,234),span("Charlie",223,229)).
start_(span("lived",230,234),span(2004,147,150)).
end_(span("lived",230,234),span(2019,155,158)).
