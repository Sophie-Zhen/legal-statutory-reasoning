% Stage 2 Generated Facts
% Case: s2_b_3_A_neg
% Text: Alice and Bob got married on Feb 3rd, 1992. Alice died on July 9th, 2014. From 2004 to 2019, Bob furnished the costs of maintaining the home where he and his father Charlie lived during that time. Bob is entitled to a deduction for Charlie under section 151(c) for the years 2015 to 2019. Bob was a nonresident alien until Feb 12, 2018.
% Question: Section 2(b)(3)(A) applies to Bob in 2019. Contradiction

:- discontiguous marriage_/1.
:- discontiguous death_/1.
:- discontiguous father_/1.
:- discontiguous payment_/1.
:- discontiguous residence_/1.
:- discontiguous nonresident_alien_/1.
:- discontiguous agent_/2.
:- discontiguous patient_/2.
:- discontiguous start_/2.
:- discontiguous end_/2.
:- discontiguous cost_of_/2.
:- discontiguous s151_c/4.
:- ['statutes/prolog/init'].
marriage_(span("married",18,24)).
agent_(span("married",18,24),span("Alice",0,4)).
agent_(span("married",18,24),span("Bob",10,12)).
start_(span("married",18,24),span(19920203,29,43)).
death_(span("died",52,55)).
agent_(span("died",52,55),span("Alice",46,50)).
start_(span("died",52,55),span(20140709,60,75)).
payment_(span("furnished the costs",101,119)).
agent_(span("payment",101,119),span("Bob",97,99)).
cost_of_(span("payment",101,119),span("home",139,142)).
start_(span("payment",101,119),span(2004,83,86)).
end_(span("payment",101,119),span(2019,91,94)).
residence_(span("lived",176,180)).
agent_(span("residence",176,180),span("he",150,151)).
agent_(span("residence",176,180),span("Charlie",168,174)).
start_(span("residence",176,180),span(2004,83,86)).
end_(span("residence",176,180),span(2019,91,94)).
father_(span("father",161,166)).
patient_(span("father",161,166),span("he",150,151)).
agent_(span("father",161,166),span("Charlie",168,174)).
s151_c("Bob","Charlie",_,2015).
s151_c("Bob","Charlie",_,2016).
s151_c("Bob","Charlie",_,2017).
s151_c("Bob","Charlie",_,2018).
s151_c("Bob","Charlie",_,2019).
nonresident_alien_(span("nonresident alien",310,326)).
agent_(span("nonresident alien",310,326),span("Bob",300,302)).
end_(span("nonresident alien",310,326),span(20180212,334,348)).
