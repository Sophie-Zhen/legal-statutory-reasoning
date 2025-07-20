% Stage 2 Generated Query
% Case: s152_b_1_neg
% Question: Section 152(b)(1) applies to Alice for the year 2015. Contradiction

answer('s152_b_1_neg', Result) :- (s152_b_1("Alice", _, 2015) -> Result = true ; Result = false).
