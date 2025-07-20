% Stage 2 Generated Facts
% Case: s2_b_1_A_i_I_neg
% Text: Alice and Bob got married on Feb 3rd, 1992. Alice and Bob have a child, Charlie, born October 9th, 2000. Alice died on July 9th, 2014. From 2004 to 2019, Bob furnished the costs of maintaining the home where he and Charlie lived during that time. Charlie married Dan on Feb 14th, 2018.
% Question: Section 2(b)(1)(A)(i)(I) applies to Charlie in 2017. Contradiction

:- discontiguous marriage_/1.
:- discontiguous agent_/2.
:- discontiguous patient_/2.
:- discontiguous start_/2.
:- discontiguous child_/1.
:- discontiguous birth_/1.
:- discontiguous death_/1.
:- discontiguous payment_/1.
:- discontiguous cost_of_/2.
:- discontiguous end_/2.
:- discontiguous residence_/1.
:- ['statutes/prolog/init'].
marriage_(span("married",18,24)).
agent_(span("married",18,24),span("Alice",0,4)).
agent_(span("married",18,24),span("Bob",10,12)).
start_(span("married",18,24),span(19920203,29,44)).
child_(span("child",68,72)).
agent_(span("child",68,72),span("Charlie",75,81)).
patient_(span("child",68,72),span("Alice",47,51)).
patient_(span("child",68,72),span("Bob",57,59)).
birth_(span("born",84,87)).
agent_(span("born",84,87),span("Charlie",75,81)).
start_(span("born",84,87),span(20001009,89,108)).
death_(span("died",117,120)).
agent_(span("died",117,120),span("Alice",111,115)).
start_(span("died",117,120),span(20140709,125,140)).
payment_(span("furnished",166,174)).
agent_(span("furnished",166,174),span("Bob",162,164)).
cost_of_(span("furnished",166,174),span("maintaining the home",185,205)).
start_(span("furnished",166,174),span(2004,148,151)).
end_(span("furnished",166,174),span(2019,156,159)).
residence_(span("lived",228,232)).
agent_(span("lived",228,232),span("Bob",162,164)).
agent_(span("lived",228,232),span("Charlie",220,226)).
start_(span("lived",228,232),span(2004,148,151)).
end_(span("lived",228,232),span(2019,156,159)).
marriage_(span("married",270,276)).
agent_(span("married",270,276),span("Charlie",262,268)).
agent_(span("married",270,276),span("Dan",278,280)).
start_(span("married",270,276),span(20180214,285,300)).
