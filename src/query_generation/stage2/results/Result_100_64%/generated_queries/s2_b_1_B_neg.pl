% Stage 2 Generated Query
% Case: s2_b_1_B_neg
% Question: Section 2(b)(1)(B) applies to Bob in 2018. Contradiction

answer('s2_b_1_B_neg', Result) :- (s2_b_1_B("Bob", _, "Charlie", _, 2018) -> Result = true ; Result = false).
