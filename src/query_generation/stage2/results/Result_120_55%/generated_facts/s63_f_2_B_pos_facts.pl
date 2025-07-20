% Stage 2 Generated Facts
% Case: s63_f_2_B_pos
% Text: In 2017, Alice was paid $33200. Alice and Bob have been married since Feb 3rd, 2017. Alice has been blind since Feb 28, 2014. In addition, Bob is allowed an exemption for Alice under section 151(b) for the year 2017.
% Question: Section 63(f)(2)(B) applies to Bob in 2017 with Alice as the spouse. Entailment

:- discontiguous s151_b_applies/2.
:- ['statutes/prolog/init'].
payment_(span("paid",20,23)).
patient_(span("paid",20,23),span("Alice",10,14)).
amount_(span("paid",20,23),span(33200,25,30)).
start_(span("paid",20,23),span(2017,3,6)).
marriage_(span("married",57,63)).
participant_(span("married",57,63),span("Alice",33,37)).
participant_(span("married",57,63),span("Bob",43,45)).
start_(span("married",57,63),span(20170203,71,84)).
blind_(span("blind",101,105)).
patient_(span("blind",101,105),span("Alice",86,90)).
start_(span("blind",101,105),span(20140228,113,125)).
s151_b_applies("Bob",2017).
