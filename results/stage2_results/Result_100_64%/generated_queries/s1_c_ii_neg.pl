% Stage 2 Generated Query
% Case: s1_c_ii_neg
% Question: Alice has to pay $1162 in taxes for the year 2017 under section 1(c)(ii). Contradiction

answer('s1_c_ii_neg', Result) :- (s1_c_ii(7748, 1162) -> Result = true ; Result = false).
