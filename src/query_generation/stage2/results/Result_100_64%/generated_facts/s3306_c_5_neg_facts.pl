% Stage 2 Generated Facts
% Case: s3306_c_5_neg
% Text: Alice has paid $3200 to her brother Bob for work done from Feb 1st, 2017 to Sep 2nd, 2017, in Baltimore, Maryland, USA.
% Question: Section 3306(c)(5) applies to Alice employing Bob for the year 2017. Contradiction

:- ['statutes/prolog/init'].
brother_(span("brother",28,34)).
patient_(span("brother",28,34),span("Alice",0,4)).
agent_(span("brother",28,34),span("Bob",36,38)).
payment_(span("paid",10,13)).
agent_(span("paid",10,13),span("Alice",0,4)).
recipient_(span("paid",10,13),span("Bob",36,38)).
amount_(span("paid",10,13),span(3200,15,19)).
purpose_(span("paid",10,13),span("work",44,47)).
work_(span("work",44,47)).
agent_(span("work",44,47),span("Bob",36,38)).
start_(span("work",44,47),span(20170201,58,71)).
end_(span("work",44,47),span(20170902,76,89)).
location_(span("work",44,47),span("Baltimore, Maryland, USA",95,120)).
