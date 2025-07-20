% Stage 2 Generated Query
% Case: s152_d_1_D_neg
% Question: Section 152(d)(1)(D) applies to Bob for the year 2015. Contradiction

answer('s152_d_1_D_neg', Result) :- (s152_d_1_D("Bob", 2015) -> Result = true ; Result = false).
