% Stage 2 Generated Facts
% Case: tax_case_57
% Text: Alice got married on Feb 29, 2000. Alice files a joint return with her spouse for 2017. Alice's gross income for the year 2017 is $22895, and her spouse's income is $14257. They take the standard deduction.
% Question: How much tax does Alice have to pay in 2017? $4073

:- ['statutes/prolog/init'].
marriage_(span("married",10,16)).
participant_(span("married",10,16),span("Alice",0,4)).
participant_(span("married",10,16),span("her spouse",66,75)).
start_(span("married",10,16),span(20000229,21,32)).
joint_return_(span("joint return",48,59)).
agent_(span("joint return",48,59),span("Alice",35,39)).
agent_(span("joint return",48,59),span("her spouse",66,75)).
start_(span("joint return",48,59),span(2017,81,84)).
income_(span("gross income",93,104)).
agent_(span("gross income",93,104),span("Alice's",87,91)).
start_(span("gross income",93,104),span(2017,114,117)).
amount_(span("gross income",93,104),span(22895,122,127)).
income_(span("income",146,151)).
agent_(span("income",146,151),span("her spouse's",134,144)).
amount_(span("income",146,151),span(14257,156,161)).
start_(span("income",146,151),span(2017,114,117)).
standard_deduction_(span("standard deduction",178,195)).
agent_(span("standard deduction",178,195),span("They",164,167)).
start_(span("standard deduction",178,195),span(2017,114,117)).
