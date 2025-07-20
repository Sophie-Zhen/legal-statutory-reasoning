% Stage 2 Generated Facts
% Case: s152_a_neg
% Text: Alice has a brother, Bob. Bob is a qualifying child of Charlie for the year 2014 under section 152(c)(1).
% Question: Under section 152(a), Bob is a dependent of Alice for the year 2014. Contradiction

:- discontiguous s152_a/3.
:- ['statutes/prolog/init'].
brother_(span("brother",12,18)).
patient_(span("brother",12,18),span("Alice",0,4)).
agent_(span("brother",12,18),span("Bob",21,23)).
s152_a("Bob","Charlie",2014).
