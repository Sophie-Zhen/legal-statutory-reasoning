% Stage 2 Generated Facts
% Case: s3306_b_10_A_pos
% Text: Alice has employed Bob from Jan 1st, 2011 to Oct 10, 2019. On Oct 10, 2019 Bob was diagnosed as disabled and retired. Alice paid Bob $12980 because she had to terminate their contract due to Bob's disability.
% Question: Section 3306(b)(10)(A) applies to the payment of $12980 that Alice made in 2019. Entailment

:- ['statutes/prolog/init'].
employment_(span("employed",10,17)).
agent_(span("employed",10,17),span("Alice",0,4)).
patient_(span("employed",10,17),span("Bob",19,21)).
start_(span("employed",10,17),span(20110101,28,41)).
end_(span("employed",10,17),span(20191010,46,58)).
diagnosis_(span("diagnosed",86,94)).
patient_(span("diagnosed",86,94),span("Bob",78,80)).
object_(span("diagnosed",86,94),span("disabled",99,106)).
start_(span("diagnosed",86,94),span(20191010,65,77)).
retirement_(span("retired",112,118)).
agent_(span("retired",112,118),span("Bob",78,80)).
start_(span("retired",112,118),span(20191010,65,77)).
payment_(span("paid",127,130)).
agent_(span("paid",127,130),span("Alice",121,125)).
patient_(span("paid",127,130),span("Bob",132,134)).
amount_(span("paid",127,130),span(12980,136,141)).
cause_(span("paid",127,130),span("Bob's disability",196,211)).
termination_(span("terminate",164,172)).
agent_(span("terminate",164,172),span("Alice",121,125)).
object_(span("terminate",164,172),span("their contract",174,187)).
cause_(span("terminate",164,172),span("Bob's disability",196,211)).
