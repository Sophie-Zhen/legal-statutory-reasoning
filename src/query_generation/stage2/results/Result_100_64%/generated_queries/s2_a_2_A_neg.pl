% Stage 2 Generated Query
% Case: s2_a_2_A_neg
% Question: Section 2(a)(2)(A) applies to Bob in 2014. Contradiction

answer('s2_a_2_A_neg', Result) :- (s2_a_2_A("Bob", _, _, _, 2014) -> Result = true ; Result = false).
