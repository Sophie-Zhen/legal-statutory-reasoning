% Stage 2 Generated Facts
% Case: s2_a_2_A_neg
% Text: Alice and Bob got married on Feb 3rd, 1992. Alice died on July 9th, 2014. Bob married Charlie on September 14th, 2015.
% Question: Section 2(a)(2)(A) applies to Bob in 2014. Contradiction

:- ['statutes/prolog/init'].
marriage_(span("married",18,24)).
agent_(span("married",18,24),span("Alice",0,4)).
agent_(span("married",18,24),span("Bob",10,12)).
start_(span("married",18,24),span(19920203,29,41)).
death_(span("died",50,53)).
agent_(span("died",50,53),span("Alice",44,48)).
start_(span("died",50,53),span(20140709,58,72)).
marriage_(span("married",79,85)).
agent_(span("married",79,85),span("Bob",75,77)).
agent_(span("married",79,85),span("Charlie",87,93)).
start_(span("married",79,85),span(20150914,98,118)).
