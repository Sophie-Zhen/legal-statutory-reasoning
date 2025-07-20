% Stage 2 Generated Query
% Case: s2_a_2_A_pos
% Question: Section 2(a)(2)(A) applies to Bob in 2015. Entailment

answer('s2_a_2_A_pos', Result) :- (s2_a_2_A("Bob", _, _, _, 2015) -> Result = true ; Result = false).
