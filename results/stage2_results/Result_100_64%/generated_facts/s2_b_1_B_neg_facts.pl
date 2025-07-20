% Stage 2 Generated Facts
% Case: s2_b_1_B_neg
% Text: Alice and Bob got married on Feb 3rd, 1992. Alice and Bob have a child, Charlie, born October 9th, 2000. Alice died on July 9th, 2014. From 2004 to 2019, Bob furnished the costs of maintaining the home where he and Charlie lived during that time. Bob is entitled to a deduction for Charlie under section 151(c) for the years 2015 to 2019.
% Question: Section 2(b)(1)(B) applies to Bob in 2018. Contradiction

:- discontiguous s151_c/4.
:- ['statutes/prolog/init'].
marriage_(span("married",18,24)).
agent_(span("married",18,24),span("Alice",0,4)).
agent_(span("married",18,24),span("Bob",10,12)).
start_(span("married",18,24),span(19920203,29,42)).
child_(span("child",67,71)).
patient_(span("child",67,71),span("Alice",46,50)).
patient_(span("child",67,71),span("Bob",56,58)).
agent_(span("child",67,71),span("Charlie",74,80)).
start_(span("child",67,71),span(20001009,88,106)).
birth_(span("born",83,86)).
agent_(span("born",83,86),span("Charlie",74,80)).
start_(span("born",83,86),span(20001009,88,106)).
death_(span("died",115,118)).
agent_(span("died",115,118),span("Alice",109,113)).
start_(span("died",115,118),span(20140709,123,137)).
payment_(span("furnished the costs",163,181)).
agent_(span("furnished the costs",163,181),span("Bob",159,161)).
cost_of_(span("furnished the costs",163,181),span("maintaining the home",186,205)).
start_(span("furnished the costs",163,181),span(2004,145,148)).
end_(span("furnished the costs",163,181),span(2019,153,156)).
residence_(span("lived",228,232)).
agent_(span("lived",228,232),span("he",213,214)).
agent_(span("lived",228,232),span("Charlie",220,226)).
location_(span("lived",228,232),span("home",202,205)).
start_(span("lived",228,232),span(2004,145,148)).
end_(span("lived",228,232),span(2019,153,156)).
s151_c("Bob","Charlie",_,2015).
s151_c("Bob","Charlie",_,2016).
s151_c("Bob","Charlie",_,2017).
s151_c("Bob","Charlie",_,2018).
s151_c("Bob","Charlie",_,2019).
