% Stage 2 Generated Query
% Case: s2_b_1_B_pos
% Question: Section 2(b)(1)(B) applies to Bob in 2018. Entailment

answer('s2_b_1_B_pos', Result) :- (s2_b_1_B("Bob", _, "Charlie", _, 2018) -> Result = true ; Result = false).
