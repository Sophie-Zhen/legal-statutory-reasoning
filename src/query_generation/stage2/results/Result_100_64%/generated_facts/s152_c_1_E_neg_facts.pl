% Stage 2 Generated Facts
% Case: s152_c_1_E_neg
% Text: Alice has a son, Bob. From September 1st, 2015 to November 3rd, 2019, Alice and Bob lived in the same home. Bob married Charlie on October 23rd, 2018. Bob and Charlie filed a joint return for the year 2019.
% Question: Section 152(c)(1)(E) applies to Bob for the year 2019. Contradiction

:- ['statutes/prolog/init'].
son_(span("son",12,14)).
patient_(span("son",12,14),span("Alice",0,4)).
agent_(span("son",12,14),span("Bob",17,19)).
residence_(span("lived",86,90)).
agent_(span("lived",86,90),span("Alice",72,76)).
agent_(span("lived",86,90),span("Bob",82,84)).
start_(span("lived",86,90),span(20150901,27,46)).
end_(span("lived",86,90),span(20191103,51,69)).
marriage_(span("married",114,120)).
agent_(span("married",114,120),span("Bob",110,112)).
agent_(span("married",114,120),span("Charlie",122,128)).
start_(span("married",114,120),span(20181023,133,151)).
joint_return_(span("filed a joint return",170,189)).
agent_(span("filed a joint return",170,189),span("Bob",154,156)).
agent_(span("filed a joint return",170,189),span("Charlie",162,168)).
start_(span("filed a joint return",170,189),span(2019,201,204)).
