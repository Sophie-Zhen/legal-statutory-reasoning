% Stage 2 Generated Facts
% Case: s63_c_2_A_ii_neg
% Text: In 2017, Alice was paid $33200. Alice and Bob have been married since Feb 3rd, 2017, and they file a joint return for 2017.
% Question: Section 63(c)(2)(A)(ii) applies to Alice in 2017. Contradiction

:- discontiguous agent_/2.
:- discontiguous start_/2.
:- discontiguous refers_to_/2.
:- ['statutes/prolog/init'].
income_(span("paid",18,21)).
agent_(span("paid",18,21),span("Alice",9,13)).
amount_(span("paid",18,21),span(33200,24,28)).
start_(span("paid",18,21),span(2017,3,6)).
marriage_(span("married",53,59)).
agent_(span("married",53,59),span("Alice",31,35)).
agent_(span("married",53,59),span("Bob",39,41)).
start_(span("married",53,59),span(20170203,67,79)).
joint_return_(span("joint return",98,109)).
agent_(span("joint return",98,109),span("they",86,89)).
refers_to_(span("they",86,89),span("Alice",31,35)).
refers_to_(span("they",86,89),span("Bob",39,41)).
start_(span("joint return",98,109),span(2017,115,118)).
