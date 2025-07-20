% Stage 2 Generated Facts
% Case: s3306_b_15_neg
% Text: Alice employed Bob for agricultural labor from Feb 1st, 2011 to November 19th, 2019. On November 25th, Bob died from a heart attack. On December 20th, 2019, Alice paid Charlie, Bob's surviving spouse, Bob's outstanding wages of $1200.
% Question: Section 3306(b)(15) applies to the payment that Alice made to Charlie in 2019. Contradiction

:- ['statutes/prolog/init'].
employment_(span("employed",6,13)).
agent_(span("employed",6,13),span("Alice",0,4)).
patient_(span("employed",6,13),span("Bob",15,17)).
type_(span("employed",6,13),span("agricultural labor",23,42)).
start_(span("employed",6,13),span(20110201,49,62)).
end_(span("employed",6,13),span(20191119,67,87)).
death_(span("died",114,117)).
agent_(span("died",114,117),span("Bob",110,112)).
start_(span("died",114,117),span(20191125,94,107)).
payment_(span("paid",170,173)).
agent_(span("paid",170,173),span("Alice",164,168)).
recipient_(span("paid",170,173),span("Charlie",175,181)).
patient_(span("paid",170,173),span("Bob",208,210)).
amount_(span("paid",170,173),span(1200,236,240)).
start_(span("paid",170,173),span(20191220,141,161)).
type_(span("paid",170,173),span("outstanding wages",214,231)).
surviving_spouse_(span("surviving spouse",190,205)).
agent_(span("surviving spouse",190,205),span("Charlie",175,181)).
patient_(span("surviving spouse",190,205),span("Bob",184,186)).
