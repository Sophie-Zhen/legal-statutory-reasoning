% Stage 2 Generated Facts
% Case: s2_b_1_A_ii_pos
% Text: Alice and Bob got married on Feb 3rd, 1992. Bob has a brother, Charlie, born October 9th, 2000. Alice died on July 9th, 2014. From 2004 to 2019, Bob furnished the costs of maintaining the home where he and Charlie lived during that time. From 2015 to 2019, Bob was entitled to a deduction for Charlie under section 151(c). In 2017, Bob earned $5254312.
% Question: Section 2(b)(1)(A)(ii) applies to Charlie as the dependent in 2017. Entailment

:- discontiguous s151_c/4.
:- ['statutes/prolog/init'].
marriage_(span("married",18,24)).
agent_(span("married",18,24),span("Alice",0,4)).
agent_(span("married",18,24),span("Bob",10,12)).
start_(span("married",18,24),span(19920203,29,42)).
brother_(span("brother",55,61)).
patient_(span("brother",55,61),span("Bob",45,47)).
agent_(span("brother",55,61),span("Charlie",64,70)).
start_(span("brother",55,61),span(20001009,78,96)).
birth_(span("born",73,76)).
agent_(span("born",73,76),span("Charlie",64,70)).
start_(span("born",73,76),span(20001009,78,96)).
death_(span("died",105,108)).
agent_(span("died",105,108),span("Alice",99,103)).
start_(span("died",105,108),span(20140709,113,128)).
furnishing_(span("furnished the costs of maintaining the home",154,196)).
agent_(span("furnished the costs of maintaining the home",154,196),span("Bob",150,152)).
start_(span("furnished the costs of maintaining the home",154,196),span(2004,136,139)).
end_(span("furnished the costs of maintaining the home",154,196),span(2019,144,147)).
residence_(span("lived",219,223)).
agent_(span("lived",219,223),span("he",204,205)).
agent_(span("lived",219,223),span("Charlie",211,217)).
start_(span("lived",219,223),span(2004,136,139)).
end_(span("lived",219,223),span(2019,144,147)).
s151_c("Bob","Charlie",_,2015).
s151_c("Bob","Charlie",_,2016).
s151_c("Bob","Charlie",_,2017).
s151_c("Bob","Charlie",_,2018).
s151_c("Bob","Charlie",_,2019).
income_(span("earned",344,349)).
agent_(span("earned",344,349),span("Bob",340,342)).
amount_(span("earned",344,349),span(5254312,351,358)).
start_(span("earned",344,349),span(2017,334,337)).
