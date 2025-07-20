% Stage 2 Generated Query
% Case: s1_d_ii_neg
% Question: Alice has to pay $33653 in taxes for the year 2017 under section 1(d)(ii). Contradiction

answer('s1_d_ii_neg', Result) :- (s1_d_ii(_, 33653) -> Result = true ; Result = false).
