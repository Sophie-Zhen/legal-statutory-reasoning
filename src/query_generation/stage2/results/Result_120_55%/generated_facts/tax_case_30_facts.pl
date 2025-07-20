% Stage 2 Generated Facts
% Case: tax_case_30
% Text: Alice's gross income for the year 2017 is $6662, Bob's gross income is $17896. Alice and Bob got married on Feb 3rd, 1992. From 2004 to 2019, Bob furnished the costs of maintaining the home where he and Alice lived during that time. In 2017, Alice and Bob file separate returns, and they both take the standard deduction.
% Question: How much tax does Alice have to pay in 2017? $249

:- discontiguous income_/1.
:- discontiguous agent_/2.
:- discontiguous amount_/2.
:- discontiguous start_/2.
:- discontiguous patient_/2.
:- discontiguous end_/2.
:- ['statutes/prolog/init'].
income_(span("income",14,19)).
agent_(span("income",14,19),span("Alice",0,4)).
amount_(span("income",14,19),span(6662,44,47)).
start_(span("income",14,19),span(2017,35,38)).
income_(span("income",62,67)).
agent_(span("income",62,67),span("Bob",50,52)).
amount_(span("income",62,67),span(17896,73,77)).
start_(span("income",62,67),span(2017,35,38)).
marriage_(span("married",98,104)).
agent_(span("married",98,104),span("Alice",80,84)).
agent_(span("married",98,104),span("Bob",90,92)).
start_(span("married",98,104),span(19920203,109,122)).
furnishing_(span("furnished",147,155)).
agent_(span("furnished",147,155),span("Bob",143,145)).
patient_(span("furnished",147,155),span("home",185,188)).
start_(span("furnished",147,155),span(2004,129,132)).
end_(span("furnished",147,155),span(2019,137,140)).
residence_(span("lived",209,213)).
agent_(span("residence",209,213),span("he",196,197)).
agent_(span("residence",209,213),span("Alice",203,207)).
location_(span("residence",209,213),span("home",185,188)).
start_(span("residence",209,213),span(2004,129,132)).
end_(span("residence",209,213),span(2019,137,140)).
filing_(span("file",261,264)).
agent_(span("filing",261,264),span("Alice",247,251)).
agent_(span("filing",261,264),span("Bob",257,259)).
start_(span("filing",261,264),span(2017,241,244)).
manner_(span("filing",261,264),span("separate returns",266,281)).
deduction_(span("take",298,301)).
agent_(span("deduction",298,301),span("they",288,291)).
patient_(span("deduction",298,301),span("standard deduction",303,320)).
start_(span("deduction",298,301),span(2017,241,244)).
