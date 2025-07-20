% Stage 2 Generated Facts
% Case: s2_a_1_B_pos
% Text: Alice and Bob got married on Feb 3rd, 1992. Alice and Bob have a child, Charlie, born October 9th, 2000. Alice died on July 9th, 2014. From 2004 to 2017, Bob furnished the costs of maintaining the home where he and Charlie lived during that time. From 2014 to 2017, Bob was entitled to a deduction for Charlie under section 151. Bob's income in 2016 was $553252.
% Question: Section 2(a)(1)(B) applies to Bob in 2016. Entailment

:- discontiguous s151_c/4.
:- ['statutes/prolog/init'].
marriage_(span("married",18,24)).
agent_(span("married",18,24),span("Alice",0,4)).
agent_(span("married",18,24),span("Bob",10,12)).
start_(span("married",18,24),span(19920203,29,42)).
child_(span("child",66,70)).
patient_(span("child",66,70),span("Alice",45,49)).
patient_(span("child",66,70),span("Bob",55,57)).
agent_(span("child",66,70),span("Charlie",73,79)).
birth_(span("born",82,85)).
agent_(span("born",82,85),span("Charlie",73,79)).
start_(span("born",82,85),span(20001009,87,105)).
death_(span("died",114,117)).
agent_(span("died",114,117),span("Alice",108,112)).
start_(span("died",114,117),span(20140709,122,136)).
payment_(span("furnished the costs",161,179)).
agent_(span("furnished the costs",161,179),span("Bob",157,159)).
patient_(span("furnished the costs",161,179),span("maintaining the home",184,204)).
start_(span("furnished the costs",161,179),span(2004,143,146)).
end_(span("furnished the costs",161,179),span(2017,151,154)).
residence_(span("lived",227,231)).
agent_(span("lived",227,231),span("he",212,213)).
agent_(span("lived",227,231),span("Charlie",219,225)).
start_(span("lived",227,231),span(2004,143,146)).
end_(span("lived",227,231),span(2017,151,154)).
s151_c("Bob","Charlie",_,2014).
