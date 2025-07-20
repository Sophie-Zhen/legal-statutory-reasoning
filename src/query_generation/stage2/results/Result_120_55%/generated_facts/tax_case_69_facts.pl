% Stage 2 Generated Facts
% Case: tax_case_69
% Text: Alice and Bob were married from Feb 3rd, 1997 to Oct 30th, 2001. Alice's gross income for the year 2014 is $718791 and she takes the standard deduction.
% Question: How much tax does Alice have to pay in 2014? $264225

:- discontiguous s63/3.
:- ['statutes/prolog/init'].
marriage_(span("married",19,25)).
agent_(span("married",19,25),span("Alice",0,4)).
agent_(span("married",19,25),span("Bob",10,12)).
start_(span("married",19,25),span(19970203,32,44)).
end_(span("married",19,25),span(20011030,49,62)).
income_(span("gross income",73,84)).
agent_(span("gross income",73,84),span("Alice",65,69)).
amount_(span("gross income",73,84),span(718791,106,112)).
start_(span("gross income",73,84),span(2014,98,101)).
takes_standard_deduction_(span("takes the standard deduction",122,149)).
agent_(span("takes the standard deduction",122,149),span("Alice",118,120)).
start_(span("takes the standard deduction",122,149),span(2014,98,101)).
