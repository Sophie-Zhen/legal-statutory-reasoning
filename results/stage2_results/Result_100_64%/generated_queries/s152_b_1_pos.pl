% Stage 2 Generated Query
% Case: s152_b_1_pos
% Question: Section 152(b)(1) applies to Bob for the year 2015. Entailment

answer('s152_b_1_pos', Result) :- (s152_b_1("Bob", _, 2015) -> Result = true ; Result = false).
