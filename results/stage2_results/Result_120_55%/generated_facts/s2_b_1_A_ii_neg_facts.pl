% Stage 2 Generated Facts
% Case: s2_b_1_A_ii_neg
% Text: Alice and Bob got married on Feb 3rd, 1992. Bob has a brother, Charlie, born October 9th, 2000. Alice died on July 9th, 2014. From 2004 to 2019, Bob furnished the costs of maintaining the home where he and Charlie lived during that time. In 2017, Charlie earned $312489. In 2017, Charlie filed a joint return with his spouse whom he married on Dec 1st, 2016.
% Question: Section 2(b)(1)(A)(ii) applies to Charlie as the dependent in 2017. Contradiction

:- discontiguous marriage_/1.
:- discontiguous agent_/2.
:- discontiguous start_/2.
:- discontiguous brother_/1.
:- discontiguous patient_/2.
:- discontiguous birth_/1.
:- discontiguous death_/1.
:- discontiguous payment_/1.
:- discontiguous end_/2.
:- discontiguous residence_/1.
:- discontiguous income_/1.
:- discontiguous amount_/2.
:- discontiguous joint_return_/1.
:- ['statutes/prolog/init'].
marriage_(span("married",18,24)).
agent_(span("married",18,24),span("Alice",0,4)).
agent_(span("married",18,24),span("Bob",10,12)).
start_(span("married",18,24),span(19920203,29,42)).
brother_(span("brother",54,60)).
patient_(span("brother",54,60),span("Bob",45,47)).
agent_(span("brother",54,60),span("Charlie",63,69)).
birth_(span("born",72,75)).
agent_(span("born",72,75),span("Charlie",63,69)).
start_(span("born",72,75),span(20001009,77,94)).
death_(span("died",102,105)).
agent_(span("died",102,105),span("Alice",96,100)).
start_(span("died",102,105),span(20140709,110,124)).
payment_(span("furnished the costs",149,167)).
agent_(span("furnished the costs",149,167),span("Bob",145,147)).
start_(span("furnished the costs",149,167),span(2004,131,134)).
end_(span("furnished the costs",149,167),span(2019,139,142)).
residence_(span("lived",220,224)).
agent_(span("lived",220,224),span("he",205,206)).
agent_(span("lived",220,224),span("Charlie",212,218)).
start_(span("lived",220,224),span(2004,131,134)).
end_(span("lived",220,224),span(2019,139,142)).
income_(span("earned",263,268)).
agent_(span("earned",263,268),span("Charlie",255,261)).
amount_(span("earned",263,268),span(312489,270,276)).
start_(span("earned",263,268),span(2017,249,252)).
joint_return_(span("filed a joint return",295,313)).
agent_(span("filed a joint return",295,313),span("Charlie",287,293)).
agent_(span("filed a joint return",295,313),span("his spouse",320,329)).
start_(span("filed a joint return",295,313),span(2017,281,284)).
marriage_(span("married",339,345)).
agent_(span("married",339,345),span("he",336,337)).
agent_(span("married",339,345),span("his spouse",320,329)).
start_(span("married",339,345),span(20161201,350,363)).
