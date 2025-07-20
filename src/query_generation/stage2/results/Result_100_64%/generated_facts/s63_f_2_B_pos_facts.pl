% Stage 2 Generated Facts
% Case: s63_f_2_B_pos
% Text: In 2017, Alice was paid $33200. Alice and Bob have been married since Feb 3rd, 2017. Alice has been blind since Feb 28, 2014. In addition, Bob is allowed an exemption for Alice under section 151(b) for the year 2017.
% Question: Section 63(f)(2)(B) applies to Bob in 2017 with Alice as the spouse. Entailment

:- discontiguous s151_b_applies/2.
:- ['statutes/prolog/init'].
payment_(span("paid",21,24)).
income_(span("paid",21,24)).
agent_(span("paid",21,24),span("Alice",10,14)).
amount_(span("paid",21,24),span(33200,26,31)).
start_(span("paid",21,24),span(2017,3,6)).
marriage_(span("married",55,61)).
agent_(span("married",55,61),span("Alice",34,38)).
agent_(span("married",55,61),span("Bob",44,46)).
start_(span("married",55,61),span(20170203,68,80)).
blindness_(span("blind",98,102)).
agent_(span("blind",98,102),span("Alice",83,87)).
start_(span("blind",98,102),span(20140228,109,120)).
s151_b_applies("Alice",2017).
