% Stage 2 Generated Query
% Case: s7703_a_1_neg
% Question: Section 7703(a)(1) applies to Alice for the year 2018. Contradiction

answer('s7703_a_1_neg', Result) :- (s7703_a_1("Alice", _, _, _, 2018) -> Result = true ; Result = false).
