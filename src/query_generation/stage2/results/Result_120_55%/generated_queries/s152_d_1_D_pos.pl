% Stage 2 Generated Query
% Case: s152_d_1_D_pos
% Question: Section 152(d)(1)(D) applies to Bob for the year 2015. Entailment

answer('s152_d_1_D_pos', Result) :- (s152_d_1_D("Bob",_,_,2015) -> Result = true ; Result = false).
