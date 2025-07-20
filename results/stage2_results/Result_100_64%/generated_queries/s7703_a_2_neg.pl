% Stage 2 Generated Query
% Case: s7703_a_2_neg
% Question: Section 7703(a)(2) applies to Alice for the year 2012. Contradiction

answer('s7703_a_2_neg', Result) :- (s7703_a_2("Alice", _, _, _, 2012) -> Result = true ; Result = false).
