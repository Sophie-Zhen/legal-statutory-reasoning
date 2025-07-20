% Stage 2 Generated Facts
% Case: s3306_b_2_C_pos
% Text: Alice has paid $45252 to Bob for work done in the year 2017. In 2017, Alice has also paid $9832 into a retirement fund for Bob, and paid $5322 into life insurance for Bob.
% Question: Section 3306(b)(2)(C) applies to the payment Alice made to the life insurance fund for the year 2017. Entailment

:- discontiguous payment_/1, agent_/2, amount_/2, start_/2, patient_/2, destination_/2, beneficiary_/2.
:- ['statutes/prolog/init'].
payment_(span("paid",10,13)).
agent_(span("paid",10,13),span("Alice",0,4)).
amount_(span("paid",10,13),span(45252,15,19)).
patient_(span("paid",10,13),span("Bob",27,29)).
start_(span("paid",10,13),span(2017,52,55)).
payment_(span("paid",74,77)).
agent_(span("paid",74,77),span("Alice",67,71)).
amount_(span("paid",74,77),span(9832,79,82)).
destination_(span("paid",74,77),span("retirement fund",91,105)).
beneficiary_(span("paid",74,77),span("Bob",111,113)).
start_(span("paid",74,77),span(2017,58,61)).
payment_(span("paid",119,122)).
agent_(span("paid",119,122),span("Alice",67,71)).
amount_(span("paid",119,122),span(5322,124,127)).
destination_(span("paid",119,122),span("life insurance",134,147)).
beneficiary_(span("paid",119,122),span("Bob",153,155)).
start_(span("paid",119,122),span(2017,58,61)).
