% Stage 2 Generated Facts
% Case: s3301_pos
% Text: Alice is an employer under section 3306(a) for the year 2015 and 2016, and she has paid $453009 in total wages in 2015, and $443870 in 2016.
% Question: Alice has to pay $27181 in excise tax for the year 2015 under section 3301. Entailment

:- discontiguous s3306_a/2.
:- ['statutes/prolog/init'].
s3306_a("Alice",2015).
s3306_a("Alice",2016).
payment_(span("paid",71,74)).
agent_(span("paid",71,74),span("Alice",0,4)).
amount_(span("paid",71,74),span(453009,77,82)).
patient_(span("paid",71,74),span("wages",93,97)).
start_(span("paid",71,74),span(2015,104,107)).
amount_(span("paid",71,74),span(443870,114,119)).
start_(span("paid",71,74),span(2016,124,127)).
