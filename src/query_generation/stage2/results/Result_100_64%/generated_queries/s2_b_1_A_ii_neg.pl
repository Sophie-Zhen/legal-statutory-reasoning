% Stage 2 Generated Query
% Case: s2_b_1_A_ii_neg
% Question: Section 2(b)(1)(A)(ii) applies to Charlie as the dependent in 2017. Contradiction

answer('s2_b_1_A_ii_neg', Result) :- (s2_b_1_A_ii(_, "charlie", 2017) -> Result = true ; Result = false).
