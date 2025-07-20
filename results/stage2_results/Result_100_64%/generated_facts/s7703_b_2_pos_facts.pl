% Stage 2 Generated Facts
% Case: s7703_b_2_pos
% Text: Alice and Bob got married on April 5th, 2012. Alice and Bob have a son, Charlie, who was born on September 16th, 2017. Alice and Charlie live in a home maintained by Alice since September 16th, 2017. Alice is entitled to a deduction for Charlie under section 151(c) for the years 2017 to 2019. Alice and Bob file a joint return for the years 2017 to 2019.
% Question: Section 7703(b)(2) applies to Alice maintaining her home for the year 2018. Entailment

:- discontiguous s151_c/4.
:- ['statutes/prolog/init'].
marriage_(span("married",18,24)).
agent_(span("married",18,24),span("Alice",0,4)).
agent_(span("married",18,24),span("Bob",10,12)).
start_(span("married",18,24),span(20120405,29,44)).
son_(span("son",69,71)).
patient_(span("son",69,71),span("Alice",47,51)).
patient_(span("son",69,71),span("Bob",57,59)).
agent_(span("son",69,71),span("Charlie",74,80)).
birth_(span("born",92,95)).
agent_(span("born",92,95),span("Charlie",74,80)).
start_(span("born",92,95),span(20170916,100,122)).
residence_(span("live in a home",142,155)).
agent_(span("live in a home",142,155),span("Alice",124,128)).
agent_(span("live in a home",142,155),span("Charlie",134,140)).
start_(span("live in a home",142,155),span(20170916,185,207)).
s151_c("Alice","Charlie",_,2017).
s151_c("Alice","Charlie",_,2018).
s151_c("Alice","Charlie",_,2019).
joint_return_(span("file a joint return",319,337)).
agent_(span("file a joint return",319,337),span("Alice",305,309)).
agent_(span("file a joint return",319,337),span("Bob",315,317)).
start_(span("file a joint return",319,337),span(2017,353,356)).
end_(span("file a joint return",319,337),span(2019,361,364)).
