% Stage 2 Generated Facts
% Case: s152_c_1_E_pos
% Text: Alice has a son, Bob. From September 1st, 2015 to November 3rd, 2019, Alice and Bob lived in the same home. Bob married Charlie on October 23rd, 2018. Bob and Charlie file separate returns.
% Question: Section 152(c)(1)(E) applies to Bob for the year 2019. Entailment

:- ['statutes/prolog/init'].
son_(span("son",12,14)).
patient_(span("son",12,14),span("Alice",0,4)).
agent_(span("son",12,14),span("Bob",17,19)).
residence_(span("lived",88,92)).
agent_(span("lived",88,92),span("Alice",74,78)).
agent_(span("lived",88,92),span("Bob",84,86)).
start_(span("lived",88,92),span(20150901,28,47)).
end_(span("lived",88,92),span(20191103,52,71)).
marriage_(span("married",105,111)).
agent_(span("married",105,111),span("Bob",101,103)).
agent_(span("married",105,111),span("Charlie",113,119)).
start_(span("married",105,111),span(20181023,124,143)).
filing_(span("file",161,164)).
agent_(span("file",161,164),span("Bob",145,147)).
agent_(span("file",161,164),span("Charlie",153,159)).
filing_status_(span("file",161,164),span("separate",166,173)).
