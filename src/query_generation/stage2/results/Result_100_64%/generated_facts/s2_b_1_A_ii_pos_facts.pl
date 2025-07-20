% Stage 2 Generated Facts
% Case: s2_b_1_A_ii_pos
% Text: Alice and Bob got married on Feb 3rd, 1992. Bob has a brother, Charlie, born October 9th, 2000. Alice died on July 9th, 2014. From 2004 to 2019, Bob furnished the costs of maintaining the home where he and Charlie lived during that time. From 2015 to 2019, Bob was entitled to a deduction for Charlie under section 151(c). In 2017, Bob earned $5254312.
% Question: Section 2(b)(1)(A)(ii) applies to Charlie as the dependent in 2017. Entailment

:- discontiguous s151_c/4.
:- ['statutes/prolog/init'].
marriage_(span("married",18,24)).
agent_(span("married",18,24),span("Alice",0,4)).
agent_(span("married",18,24),span("Bob",10,12)).
start_(span("married",18,24),span(19920203,29,43)).
brother_(span("brother",56,62)).
patient_(span("brother",56,62),span("Bob",46,48)).
agent_(span("brother",56,62),span("Charlie",65,71)).
start_(span("brother",56,62),span(20001009,79,97)).
birth_(span("born",74,77)).
agent_(span("born",74,77),span("Charlie",65,71)).
start_(span("born",74,77),span(20001009,79,97)).
death_(span("died",106,109)).
agent_(span("death",106,109),span("Alice",100,104)).
start_(span("death",106,109),span(20140709,114,128)).
furnishing_(span("furnished the costs",154,172)).
agent_(span("furnishing",154,172),span("Bob",150,152)).
patient_(span("furnishing",154,172),span("home",192,195)).
start_(span("furnishing",154,172),span(2004,136,139)).
end_(span("furnishing",154,172),span(2019,144,147)).
residence_(span("lived",217,221)).
agent_(span("lived",217,221),span("he",202,203)).
agent_(span("lived",217,221),span("Charlie",209,215)).
start_(span("lived",217,221),span(2004,136,139)).
end_(span("lived",217,221),span(2019,144,147)).
s151_c("Bob","Charlie",_,2015).
s151_c("Bob","Charlie",_,2016).
s151_c("Bob","Charlie",_,2017).
s151_c("Bob","Charlie",_,2018).
s151_c("Bob","Charlie",_,2019).
income_(span("earned",337,342)).
agent_(span("earned",337,342),span("Bob",333,335)).
amount_(span("earned",337,342),span(5254312,344,352)).
start_(span("earned",337,342),span(2017,327,330)).
