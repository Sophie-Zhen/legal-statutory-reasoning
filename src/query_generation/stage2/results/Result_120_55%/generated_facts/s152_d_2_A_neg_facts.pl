% Stage 2 Generated Facts
% Case: s152_d_2_A_neg
% Text: Bob is Alice's brother since April 15th, 2014.
% Question: Alice bears a relationship to Bob under section 152(d)(2)(A). Contradiction

:- ['statutes/prolog/init'].
brother_(span("brother",15,21)).
agent_(span("brother",15,21),span("Bob",0,2)).
patient_(span("brother",15,21),span("Alice's",7,13)).
start_(span("brother",15,21),span(20140415,29,44)).
