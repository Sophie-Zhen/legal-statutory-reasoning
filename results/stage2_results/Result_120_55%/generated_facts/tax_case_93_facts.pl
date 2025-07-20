% Stage 2 Generated Facts
% Case: tax_case_93
% Text: Bob is Alice's father. Alice's gross income in 2015 is $311510. Bob has no income in 2015. Alice takes the standard deduction in 2015.
% Question: How much tax does Alice have to pay in 2015? $102150

:- ['statutes/prolog/init'].
father_(span("father",17,22)).
agent_(span("father",17,22),span("Bob",0,2)).
patient_(span("father",17,22),span("Alice",7,11)).
income_(span("income",38,43)).
agent_(span("income",38,43),span("Alice",24,28)).
start_(span("income",38,43),span(2015,48,51)).
amount_(span("income",38,43),span(311510,59,65)).
income_(span("income",80,85)).
agent_(span("income",80,85),span("Bob",69,71)).
amount_(span("income",80,85),span(0,76,77)).
start_(span("income",80,85),span(2015,90,93)).
takes_(span("takes",103,107)).
agent_(span("takes",103,107),span("Alice",97,101)).
patient_(span("takes",103,107),span("standard deduction",109,126)).
start_(span("takes",103,107),span(2015,131,134)).
