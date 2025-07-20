% Stage 2 Generated Query
% Case: s68_b_1_C_pos
% Question: Section 68(b)(1)(C) applies to Alice in 2016 with the applicable amount equal to $250000. Entailment

answer('s68_b_1_C_pos', Result) :- (s68_b_1_C("Alice", 250000, 2016) -> Result = true ; Result = false).
