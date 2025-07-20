% Stage 2 Generated Facts
% Case: s3306_c_13_pos
% Text: Alice was paid $3200 in 2017 for services performed for Johns Hopkins School of Nursing. Alice was enrolled at Johns Hopkins School of Nursing and attending classes from August 29, 2015 to May 30th, 2019.
% Question: Section 3306(c)(13) applies to Alice's employment situation in 2017. Entailment

:- ['statutes/prolog/init'].
payment_(span("paid",10,13)).
agent_(span("paid",10,13),span("Johns Hopkins School of Nursing",56,86)).
patient_(span("paid",10,13),span("Alice",0,4)).
amount_(span("paid",10,13),span(3200,15,19)).
start_(span("paid",10,13),span(2017,24,27)).
end_(span("paid",10,13),span(2017,24,27)).
service_(span("services performed",33,50)).
agent_(span("services performed",33,50),span("Alice",0,4)).
patient_(span("services performed",33,50),span("Johns Hopkins School of Nursing",56,86)).
start_(span("services performed",33,50),span(2017,24,27)).
end_(span("services performed",33,50),span(2017,24,27)).
enrollment_(span("enrolled",99,106)).
agent_(span("enrolled",99,106),span("Alice",89,93)).
patient_(span("enrolled",99,106),span("Johns Hopkins School of Nursing",111,141)).
start_(span("enrolled",99,106),span(20150829,170,185)).
end_(span("enrolled",99,106),span(20190530,190,204)).
attending_(span("attending classes",147,163)).
agent_(span("attending classes",147,163),span("Alice",89,93)).
start_(span("attending classes",147,163),span(20150829,170,185)).
end_(span("attending classes",147,163),span(20190530,190,204)).
