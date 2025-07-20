% Stage 2 Generated Facts
% Case: s3306_b_7_neg
% Text: Alice has been running a typewriter factory since February 1st, 2016. Bob is an employee at the typewriter factory. On October 2nd 2017, Alice has paid Bob $323 in cash for painting her house.
% Question: Section 3306(b)(7) applies to the payment Alice made to Bob. Contradiction

:- ['statutes/prolog/init'].
running_(span("running",15,21)).
agent_(span("running",15,21),span("Alice",0,4)).
patient_(span("running",15,21),span("typewriter factory",25,42)).
start_(span("running",15,21),span(20160201,50,68)).
employee_(span("employee",81,88)).
agent_(span("employee",81,88),span("Bob",71,73)).
location_(span("employee",81,88),span("typewriter factory",97,114)).
payment_(span("paid",149,152)).
agent_(span("paid",149,152),span("Alice",139,143)).
recipient_(span("paid",149,152),span("Bob",154,156)).
amount_(span("paid",149,152),span(323,158,161)).
medium_(span("paid",149,152),span("cash",166,169)).
purpose_(span("paid",149,152),span("painting her house",175,192)).
start_(span("paid",149,152),span(20171002,119,136)).
painting_(span("painting",175,182)).
agent_(span("painting",175,182),span("Bob",154,156)).
patient_(span("painting",175,182),span("her house",184,192)).
possessor_(span("her house",184,192),span("Alice",139,143)).
