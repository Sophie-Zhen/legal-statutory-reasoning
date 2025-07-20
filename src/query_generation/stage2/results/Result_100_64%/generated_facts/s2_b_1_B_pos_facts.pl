% Stage 2 Generated Facts
% Case: s2_b_1_B_pos
% Text: Alice and Bob got married on Feb 3rd, 1992. Alice died on July 9th, 2014. From 2004 to 2019, Bob furnished the costs of maintaining the home where he and his father Charlie lived during that time. Bob is entitled to a deduction for Charlie under section 151(c) for the years 2015 to 2019.
% Question: Section 2(b)(1)(B) applies to Bob in 2018. Entailment

:- discontiguous s151_c/4.
:- ['statutes/prolog/init'].
marriage_(span("married",18,24)).
agent_(span("married",18,24),span("Alice",0,4)).
patient_(span("married",18,24),span("Bob",10,12)).
start_(span("married",18,24),span(19920203,29,42)).
death_(span("died",51,54)).
agent_(span("died",51,54),span("Alice",45,49)).
start_(span("died",51,54),span(20140709,59,73)).
payment_(span("furnished",100,108)).
agent_(span("furnished",100,108),span("Bob",95,98)).
start_(span("furnished",100,108),span(2004,81,84)).
end_(span("furnished",100,108),span(2019,89,92)).
father_(span("father",165,170)).
agent_(span("father",165,170),span("Charlie",172,178)).
patient_(span("father",165,170),span("he",154,155)).
residence_(span("lived",180,184)).
agent_(span("lived",180,184),span("he",154,155)).
agent_(span("lived",180,184),span("Charlie",172,178)).
start_(span("lived",180,184),span(2004,81,84)).
end_(span("lived",180,184),span(2019,89,92)).
s151_c("Bob","Charlie",_,2015).
s151_c("Bob","Charlie",_,2016).
s151_c("Bob","Charlie",_,2017).
s151_c("Bob","Charlie",_,2018).
s151_c("Bob","Charlie",_,2019).
