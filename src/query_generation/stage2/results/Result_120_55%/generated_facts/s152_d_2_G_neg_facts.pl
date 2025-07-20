% Stage 2 Generated Facts
% Case: s152_d_2_G_neg
% Text: Alice and Bob started living together on April 15th, 2014. Alice and Bob are not related, nor do they have relatives married to one another.
% Question: Alice bears a relationship to Bob under section 152(d)(2)(G) for the year 2018. Contradiction

:- ['statutes/prolog/init'].
residence_(span("living together",20,33)).
agent_(span("living together",20,33),span("Alice",0,4)).
agent_(span("living together",20,33),span("Bob",9,11)).
start_(span("living together",20,33),span(20140415,40,56)).
