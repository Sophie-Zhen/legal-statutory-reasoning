% Stage 2 Generated Facts
% Case: s63_f_1_B_pos
% Text: In 2017, Alice was paid $33200. Alice and Bob have been married since Feb 3rd, 2017. Alice was born March 2nd, 1950 and Bob was born March 3rd, 1955. In addition, Bob is allowed an exemption for Alice under section 151(b) for the year 2017.
% Question: Section 63(f)(1)(B) applies to Bob with Alice as the spouse in 2017. Entailment

:- discontiguous income_/1.
:- discontiguous marriage_/1.
:- discontiguous birth_/1.
:- discontiguous s152_a/3.
:- ['statutes/prolog/init'].
income_(span("paid",22,25)).
agent_(span("paid",22,25),span("Alice",10,14)).
amount_(span("paid",22,25),span(33200,27,32)).
start_(span("paid",22,25),span(2017,3,6)).
marriage_(span("married",51,57)).
agent_(span("married",51,57),span("Alice",35,39)).
agent_(span("married",51,57),span("Bob",45,47)).
start_(span("married",51,57),span(20170203,65,77)).
birth_(span("born",86,89)).
agent_(span("born",86,89),span("Alice",80,84)).
start_(span("born",86,89),span(19500302,91,105)).
birth_(span("born",115,118)).
agent_(span("born",115,118),span("Bob",111,113)).
start_(span("born",115,118),span(19550303,120,134)).
s152_a("Alice","Bob",2017).
