% Stage 2 Generated Facts
% Case: s3306_c_13_neg
% Text: Alice was paid $3200 in 2017 for services performed for Johns Hopkins University. Alice was enrolled as a physics major at Johns Hopkins University and attending classes from August 29, 2015 to May 30th, 2019.
% Question: Section 3306(c)(13) applies to Alice's employment situation in 2017. Contradiction

:- ['statutes/prolog/init'].
income_(span("paid",10,13)).
patient_(span("paid",10,13),span("Alice",0,4)).
agent_(span("paid",10,13),span("Johns Hopkins University",55,78)).
amount_(span("paid",10,13),span(3200,15,19)).
start_(span("paid",10,13),span(2017,24,27)).
enrollment_(span("enrolled",93,100)).
agent_(span("enrolled",93,100),span("Alice",81,85)).
patient_(span("enrolled",93,100),span("Johns Hopkins University",125,148)).
start_(span("enrolled",93,100),span(20150829,170,186)).
end_(span("enrolled",93,100),span(20190530,191,206)).
attending_classes_(span("attending classes",154,169)).
agent_(span("attending classes",154,169),span("Alice",81,85)).
start_(span("attending classes",154,169),span(20150829,170,186)).
end_(span("attending classes",154,169),span(20190530,191,206)).
