% Stage 2 Generated Facts
% Case: s68_a_2_pos
% Text: In 2016, Alice's income was $277192. Alice is a head of household for the year 2016. Alice is allowed itemized deductions of $60000 under section 63.
% Question: Section 68(a)(2) prescribes a reduction of Alice's itemized deductions for the year 2016 by $48000. Entailment

:- discontiguous s2_b/3.
:- discontiguous s63_d/3.
:- discontiguous income_/1.
:- discontiguous agent_/2.
:- discontiguous amount_/2.
:- discontiguous start_/2.
:- ['statutes/prolog/init'].
s2_b("Alice",_,2016).
s63_d("Alice",60000,2016).
income_(span("income",20,25)).
agent_(span("income",20,25),span("Alice",10,14)).
amount_(span("income",20,25),span(277192,30,36)).
