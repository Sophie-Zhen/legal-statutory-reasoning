% Stage 2 Generated Facts
% Case: s2_b_1_A_i_II_pos
% Text: Alice and Bob got married on Feb 3rd, 1992. Alice and Bob have a child, Charlie, born October 9th, 2000. Alice died on July 9th, 2014. From 2004 to 2019, Bob furnished the costs of maintaining the home where he and Charlie lived during that time. Charlie married Dan on Feb 14th, 2018. Section 152(b)(2) applies to Charlie as the dependent and Bob as the taxpayer for 2018.
% Question: Section 2(b)(1)(A)(i)(II) applies to Bob with Charlie as the qualifying child in 2018. Entailment

:- discontiguous s152_b_2_applies/3.
:- discontiguous marriage_/1.
:- discontiguous agent_/2.
:- discontiguous start_/2.
:- discontiguous child_/1.
:- discontiguous patient_/2.
:- discontiguous birth_/1.
:- discontiguous death_/1.
:- discontiguous furnishing_/1.
:- discontiguous end_/2.
:- discontiguous residence_/1.
:- discontiguous location_/2.
:- ['statutes/prolog/init'].
marriage_(span("married",18,24)).
agent_(span("married",18,24),span("Alice",0,4)).
agent_(span("married",18,24),span("Bob",10,12)).
start_(span("married",18,24),span(19920203,29,42)).
child_(span("child",67,71)).
patient_(span("child",67,71),span("Alice",45,49)).
patient_(span("child",67,71),span("Bob",55,57)).
agent_(span("child",67,71),span("Charlie",74,80)).
birth_(span("born",83,86)).
agent_(span("born",83,86),span("Charlie",74,80)).
start_(span("born",83,86),span(20001009,88,106)).
death_(span("died",115,118)).
agent_(span("died",115,118),span("Alice",109,113)).
start_(span("died",115,118),span(20140709,123,138)).
furnishing_(span("furnished",165,173)).
agent_(span("furnished",165,173),span("Bob",161,163)).
patient_(span("furnished",165,173),span("home",206,209)).
start_(span("furnished",165,173),span(2004,146,149)).
end_(span("furnished",165,173),span(2019,154,157)).
residence_(span("lived",232,236)).
agent_(span("lived",232,236),span("Bob",161,163)).
agent_(span("lived",232,236),span("Charlie",224,230)).
location_(span("lived",232,236),span("home",206,209)).
start_(span("lived",232,236),span(2004,146,149)).
end_(span("lived",232,236),span(2019,154,157)).
marriage_(span("married",272,278)).
agent_(span("married",272,278),span("Charlie",264,270)).
agent_(span("married",272,278),span("Dan",280,282)).
start_(span("married",272,278),span(20180214,287,301)).
s152_b_2_applies("Charlie","Bob",2018).
