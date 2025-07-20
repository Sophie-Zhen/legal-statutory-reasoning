% Stage 2 Generated Facts
% Case: s3301_pos
% Text: Alice is an employer under section 3306(a) for the year 2015 and 2016, and she has paid $453009 in total wages in 2015, and $443870 in 2016.
% Question: Alice has to pay $27181 in excise tax for the year 2015 under section 3301. Entailment

:- discontiguous s3306_a_1/2, amount_/2, start_/2.
:- ['statutes/prolog/init'].
s3306_a_1("Alice",2015).
s3306_a_1("Alice",2016).
payment_(span("paid",83,86)).
agent_(span("paid",83,86),span("Alice",0,4)).
amount_(span("paid",83,86),span(453009,88,94)).
start_(span("paid",83,86),span(2015,111,114)).
amount_(span("paid",83,86),span(443870,122,128)).
start_(span("paid",83,86),span(2016,134,137)).
wages_(span("wages",103,107)).
patient_(span("wages",103,107),span("paid",83,86)).
