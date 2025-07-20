% Stage 2 Generated Query
% Case: s152_c_1_E_neg
% Question: Section 152(c)(1)(E) applies to Bob for the year 2019. Contradiction

answer('s152_c_1_E_neg', Result) :- (s152_c_1_E("Bob", _, 2019) -> Result = true ; Result = false).
