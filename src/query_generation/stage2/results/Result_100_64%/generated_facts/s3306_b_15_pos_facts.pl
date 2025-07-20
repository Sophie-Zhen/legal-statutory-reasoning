% Stage 2 Generated Facts
% Case: s3306_b_15_pos
% Text: Alice employed Bob for agricultural labor from Feb 1st, 2011 to November 19th, 2019. On November 25th, Bob died from a heart attack. On January 20th, 2020, Alice paid Charlie, Bob's surviving spouse, Bob's outstanding wages of $1200.
% Question: Section 3306(b)(15) applies to the payment that Alice made to Charlie in 2020. Entailment

:- ['statutes/prolog/init'].
employment_(span("employed",6,13)).
agent_(span("employed",6,13),span("Alice",0,4)).
patient_(span("employed",6,13),span("Bob",15,17)).
type_(span("employed",6,13),span("agricultural labor",23,41)).
start_(span("employed",6,13),span(20110201,48,61)).
end_(span("employed",6,13),span(20191119,66,86)).
death_(span("died",112,115)).
agent_(span("died",112,115),span("Bob",108,110)).
start_(span("died",112,115),span(20191125,92,105)).
payment_(span("paid",170,173)).
agent_(span("paid",170,173),span("Alice",164,168)).
patient_(span("paid",170,173),span("Charlie",175,181)).
start_(span("paid",170,173),span(20200120,143,161)).
amount_(span("paid",170,173),span(1200,236,240)).
description_(span("paid",170,173),span("Bob's outstanding wages",207,231)).
surviving_spouse_(span("surviving spouse",189,204)).
agent_(span("surviving spouse",189,204),span("Charlie",175,181)).
patient_(span("surviving spouse",189,204),span("Bob",184,186)).
