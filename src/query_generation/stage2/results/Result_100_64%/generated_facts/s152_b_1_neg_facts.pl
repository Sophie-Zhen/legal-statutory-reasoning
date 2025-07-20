% Stage 2 Generated Facts
% Case: s152_b_1_neg
% Text: Alice has a son, Bob, who satisfies section 152(c)(1) for the year 2015. Bob has a son, Charlie, who satisfies section 152(c)(1) for the year 2015. Alice's income in 2015 was $504598. Bob had no income in 2015.
% Question: Section 152(b)(1) applies to Alice for the year 2015. Contradiction

:- discontiguous s152_c_1_applies/3.
:- ['statutes/prolog/init'].
s152_c_1_applies("Bob","Alice",2015).
s152_c_1_applies("Charlie","Bob",2015).
son_(span("son",12,14)).
patient_(span("son",12,14),span("Alice",0,4)).
agent_(span("son",12,14),span("Bob",17,19)).
son_(span("son",83,85)).
patient_(span("son",83,85),span("Bob",73,75)).
agent_(span("son",83,85),span("Charlie",88,94)).
income_(span("income",156,161)).
agent_(span("income",156,161),span("Alice",148,152)).
amount_(span("income",156,161),span(504598,175,181)).
start_(span("income",156,161),span(2015,166,169)).
income_(span("income",196,201)).
agent_(span("income",196,201),span("Bob",184,186)).
amount_(span("income",196,201),span(0,192,200)).
start_(span("income",196,201),span(2015,205,208)).
