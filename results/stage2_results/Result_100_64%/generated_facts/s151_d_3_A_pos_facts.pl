% Stage 2 Generated Facts
% Case: s151_d_3_A_pos
% Text: Alice's income in 2015 was $260932. For 2015, Alice received one exemption of $2000 under section 151(c). Alice's applicable percentage under section 151(d)(3)(B) is equal to 10%.
% Question: Under section 151(d)(3)(A), Alice's exemption amount is reduced to $1800. Entailment

:- discontiguous s151_c/4.
:- discontiguous s151_d_3_B/3.
:- ['statutes/prolog/init'].
income_(span("income",8,13)).
agent_(span("income",8,13),span("Alice's",0,6)).
start_(span("income",8,13),span(2015,18,21)).
amount_(span("income",8,13),span(260932,27,34)).
s151_c("Alice",_,2000,2015).
s151_d_3_B("Alice",10,2015).
