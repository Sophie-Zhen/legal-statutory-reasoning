% Stage 2 Generated Facts
% Case: s2_b_3_A_pos
% Text: Alice and Bob got married on Feb 3rd, 1992. Alice died on July 9th, 2014. From 2004 to 2019, Bob furnished the costs of maintaining the home where he and his father Charlie lived during that time. Bob is entitled to a deduction for Charlie under section 151(c) for the years 2015 to 2019. Bob was a nonresident alien until Feb 12, 2018.
% Question: Section 2(b)(3)(A) applies to Bob in 2018. Entailment

:- discontiguous s151_c/4.
:- ['statutes/prolog/init'].
marriage_(span("married",18,24)).
agent_(span("married",18,24),span("Alice",0,4)).
agent_(span("married",18,24),span("Bob",10,12)).
start_(span("married",18,24),span(19920203,29,42)).
death_(span("died",51,54)).
agent_(span("died",51,54),span("Alice",45,49)).
start_(span("died",51,54),span(20140709,59,74)).
payment_(span("furnished the costs",100,118)).
agent_(span("furnished the costs",100,118),span("Bob",96,98)).
beneficiary_(span("furnished the costs",100,118),span("the home",136,143)).
start_(span("furnished the costs",100,118),span(2004,82,85)).
end_(span("furnished the costs",100,118),span(2019,90,93)).
residence_(span("lived",176,180)).
agent_(span("lived",176,180),span("he",150,151)).
agent_(span("lived",176,180),span("Charlie",168,174)).
location_(span("lived",176,180),span("the home",136,143)).
start_(span("lived",176,180),span(2004,82,85)).
end_(span("lived",176,180),span(2019,90,93)).
father_(span("father",161,166)).
patient_(span("father",161,166),span("he",150,151)).
agent_(span("father",161,166),span("Charlie",168,174)).
s151_c("Bob","Charlie",_,2015).
s151_c("Bob","Charlie",_,2016).
s151_c("Bob","Charlie",_,2017).
s151_c("Bob","Charlie",_,2018).
s151_c("Bob","Charlie",_,2019).
nonresident_alien_(span("nonresident alien",318,334)).
agent_(span("nonresident alien",318,334),span("Bob",308,310)).
end_(span("nonresident alien",318,334),span(20180212,342,353)).
