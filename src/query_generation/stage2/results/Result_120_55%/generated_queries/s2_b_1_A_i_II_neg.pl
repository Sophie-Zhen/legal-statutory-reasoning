% Stage 2 Generated Query
% Case: s2_b_1_A_i_II_neg
% Question: Section 2(b)(1)(A)(i)(II) applies to Bob with Charlie as the qualifying child in 2018. Contradiction

answer('s2_b_1_A_i_II_neg', Result) :- (s2_b_1_A_i_II("Charlie", "Bob", 2018) -> Result = true ; Result = false).
