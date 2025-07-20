% Stage 2 Generated Facts
% Case: s63_f_2_B_neg
% Text: In 2017, Alice was paid $33200. Alice and Bob have been married since Feb 3rd, 2017. Alice has been blind since October 4, 2013. In addition, Alice is allowed an exemption for Bob under section 151(b) for the year 2017.
% Question: Section 63(f)(2)(B) applies to Alice in 2017 with Bob as the spouse. Contradiction

:- discontiguous agent_/2.
:- discontiguous amount_/2.
:- discontiguous blindness_/1.
:- discontiguous income_/1.
:- discontiguous marriage_/1.
:- discontiguous s152_a/3.
:- discontiguous start_/2.
:- ['statutes/prolog/init'].
s152_a("Bob","Alice",2017).
income_(span("paid",19,22)).
agent_(span("paid",19,22),span("Alice",9,13)).
amount_(span("paid",19,22),span(33200,24,29)).
start_(span("paid",19,22),span(2017,3,6)).
marriage_(span("married",55,61)).
agent_(span("married",55,61),span("Alice",32,36)).
agent_(span("married",55,61),span("Bob",42,44)).
start_(span("married",55,61),span(20170203,68,81)).
blindness_(span("blind",99,103)).
agent_(span("blind",99,103),span("Alice",84,88)).
start_(span("blind",99,103),span(20131004,111,127)).
