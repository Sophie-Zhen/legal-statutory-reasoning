% Stage 2 Generated Query
% Case: s152_c_1_E_pos
% Question: Section 152(c)(1)(E) applies to Bob for the year 2019. Entailment

answer('s152_c_1_E_pos', Result) :- (s152_c_1_E("Bob", _, 2019) -> Result = true ; Result = false).
