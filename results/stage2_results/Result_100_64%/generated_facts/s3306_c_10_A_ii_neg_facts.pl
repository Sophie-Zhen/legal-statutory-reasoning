% Stage 2 Generated Facts
% Case: s3306_c_10_A_ii_neg
% Text: Alice's father, Bob, was paid $3200 in 2017 for services performed for Johns Hopkins University. Alice was enrolled at Johns Hopkins University and attending classes from August 29, 2015 to May 30th, 2019.
% Question: Section 3306(c)(10)(A)(ii) applies to Bob's employment situation in 2017. Contradiction

:- discontiguous s3306_c_10_A_ii_applies/3.
:- ['statutes/prolog/init'].
father_(span("father",8,13)).
patient_(span("father",8,13),span("Alice",0,4)).
agent_(span("father",8,13),span("Bob",16,18)).
payment_(span("paid",25,28)).
agent_(span("paid",25,28),span("Bob",16,18)).
amount_(span("paid",25,28),3200).
start_(span("paid",25,28),span(2017,38,41)).
service_(span("services performed",47,64)).
agent_(span("services performed",47,64),span("Bob",16,18)).
patient_(span("services performed",47,64),span("Johns Hopkins University",70,93)).
start_(span("services performed",47,64),span(2017,38,41)).
enrollment_(span("enrolled",106,113)).
agent_(span("enrolled",106,113),span("Alice",96,100)).
patient_(span("enrolled",106,113),span("Johns Hopkins University",118,141)).
start_(span("enrolled",106,113),span(20150829,170,184)).
end_(span("enrolled",106,113),span(20190530,189,203)).
class_attendance_(span("attending classes",147,163)).
agent_(span("attending classes",147,163),span("Alice",96,100)).
start_(span("attending classes",147,163),span(20150829,170,184)).
end_(span("attending classes",147,163),span(20190530,189,203)).
s3306_c_10_A_ii_applies("Bob","Johns Hopkins University",2017).
contradiction.
