% Stage 2 Generated Facts
% Case: s152_c_1_B_neg
% Text: Alice has a son, Bob. From September 1st, 2015 to November 3rd, 2019, Alice and Bob lived in the same home.
% Question: Section 152(c)(1)(B) applies to Bob with Alice as the taxpayer for the year 2015. Contradiction

:- ['statutes/prolog/init'].
son_(span("son",12,14)).
patient_(span("son",12,14),span("Alice",0,4)).
agent_(span("son",12,14),span("Bob",17,19)).
residence_(span("lived",86,90)).
agent_(span("lived",86,90),span("Alice",72,76)).
agent_(span("lived",86,90),span("Bob",82,84)).
start_(span("lived",86,90),span(20150901,26,45)).
end_(span("lived",86,90),span(20191103,50,69)).
