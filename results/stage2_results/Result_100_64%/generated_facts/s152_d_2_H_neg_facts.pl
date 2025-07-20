% Stage 2 Generated Facts
% Case: s152_d_2_H_neg
% Text: Bob is Alice's father since April 15th, 1994. In 2015, Alice and Bob live in separate houses.
% Question: Alice bears a relationship to Bob under section 152(d)(2)(H) for the year 2015. Contradiction

:- ['statutes/prolog/init'].
father_(span("father",16,21)).
agent_(span("father",16,21),span("Bob",0,2)).
patient_(span("father",16,21),span("Alice",7,11)).
start_(span("father",16,21),span(19940415,29,45)).
