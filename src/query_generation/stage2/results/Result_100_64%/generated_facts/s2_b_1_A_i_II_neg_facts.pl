% Stage 2 Generated Facts
% Case: s2_b_1_A_i_II_neg
% Text: Alice and Bob got married on Feb 3rd, 1992. Alice and Bob have a child, Charlie, born October 9th, 2000. Alice died on July 9th, 2014. From 2004 to 2019, Bob furnished the costs of maintaining the home where he and Charlie lived during that time. Charlie married Dan on Feb 14th, 2018.
% Question: Section 2(b)(1)(A)(i)(II) applies to Bob with Charlie as the qualifying child in 2018. Contradiction

:- discontiguous marriage_/1.
:- discontiguous agent_/2.
:- discontiguous start_/2.
:- discontiguous child_/1.
:- discontiguous patient_/2.
:- discontiguous birth_/1.
:- discontiguous death_/1.
:- discontiguous payment_/1.
:- discontiguous end_/2.
:- discontiguous residence_/1.
:- discontiguous location_/2.
:- ['statutes/prolog/init'].
marriage_(span("married",18,24)).
agent_(span("married",18,24),span("Alice",0,4)).
agent_(span("married",18,24),span("Bob",10,12)).
start_(span("married",18,24),span(19920203,29,41)).
child_(span("child",61,65)).
patient_(span("child",61,65),span("Alice",44,48)).
patient_(span("child",61,65),span("Bob",54,56)).
agent_(span("child",61,65),span("Charlie",68,74)).
birth_(span("born",77,80)).
agent_(span("born",77,80),span("Charlie",68,74)).
start_(span("born",77,80),span(20001009,82,100)).
death_(span("died",109,112)).
agent_(span("died",109,112),span("Alice",103,107)).
start_(span("died",109,112),span(20140709,117,131)).
payment_(span("furnished the costs of maintaining the home",156,198)).
agent_(span("furnished the costs of maintaining the home",156,198),span("Bob",152,154)).
start_(span("furnished the costs of maintaining the home",156,198),span(2004,138,141)).
end_(span("furnished the costs of maintaining the home",156,198),span(2019,146,149)).
residence_(span("lived",220,224)).
agent_(span("lived",220,224),span("Bob",152,154)).
agent_(span("lived",220,224),span("Charlie",68,74)).
location_(span("lived",220,224),span("home",194,197)).
start_(span("lived",220,224),span(2004,138,141)).
end_(span("lived",220,224),span(2019,146,149)).
marriage_(span("married",251,257)).
agent_(span("married",251,257),span("Charlie",243,249)).
agent_(span("married",251,257),span("Dan",259,261)).
start_(span("married",251,257),span(20180214,266,280)).
