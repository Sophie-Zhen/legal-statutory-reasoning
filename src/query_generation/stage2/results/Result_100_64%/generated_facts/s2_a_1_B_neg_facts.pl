% Stage 2 Generated Facts
% Case: s2_a_1_B_neg
% Text: Alice and Bob were married from Feb 3rd, 1992 to Jan 14th, 2020. Alice has a child, Charlie, born October 9th, 2000. Alice died on July 9th, 2021. From 2011 to 2024, Bob furnished the costs of maintaining the home where he and Charlie lived during that time. In 2020, Charlie filed a joint return with his spouse whom he married on Dec 1st, 2020. Charlie earned $312489 in 2020.
% Question: Section 2(a)(1)(B) applies to Bob in 2020. Contradiction

:- ['statutes/prolog/init'].
marriage_(span("married",19,25)).
agent_(span("married",19,25),span("Alice",0,4)).
agent_(span("married",19,25),span("Bob",10,12)).
start_(span("married",19,25),span(19920203,31,43)).
end_(span("married",19,25),span(20200114,48,62)).
child_(span("child",77,81)).
patient_(span("child",77,81),span("Alice",65,69)).
agent_(span("child",77,81),span("Charlie",84,90)).
birth_(span("born",93,96)).
agent_(span("born",93,96),span("Charlie",84,90)).
start_(span("born",93,96),span(20001009,98,116)).
death_(span("died",125,128)).
agent_(span("died",125,128),span("Alice",119,123)).
start_(span("died",125,128),span(20210709,133,147)).
furnish_(span("furnished",173,181)).
agent_(span("furnished",173,181),span("Bob",169,171)).
patient_(span("furnished",173,181),span("costs of maintaining the home",187,217)).
start_(span("furnished",173,181),span(2011,155,158)).
end_(span("furnished",173,181),span(2024,163,166)).
residence_(span("lived",240,244)).
agent_(span("lived",240,244),span("he",225,226)).
agent_(span("lived",240,244),span("Charlie",232,238)).
start_(span("lived",240,244),span(2011,155,158)).
end_(span("lived",240,244),span(2024,163,166)).
joint_return_(span("filed a joint return",277,297)).
agent_(span("filed a joint return",277,297),span("Charlie",269,275)).
agent_(span("filed a joint return",277,297),span("his spouse",304,313)).
start_(span("filed a joint return",277,297),span(2020,263,266)).
marriage_(span("married",320,326)).
agent_(span("married",320,326),span("he",315,316)).
agent_(span("married",320,326),span("his spouse",304,313)).
start_(span("married",320,326),span(20201201,331,344)).
income_(span("earned",355,360)).
agent_(span("earned",355,360),span("Charlie",347,353)).
amount_(span("earned",355,360),span(312489,362,368)).
start_(span("earned",355,360),span(2020,373,376)).
