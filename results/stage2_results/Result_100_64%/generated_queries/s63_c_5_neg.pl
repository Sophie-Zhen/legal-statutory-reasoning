% Stage 2 Generated Query
% Case: s63_c_5_neg
% Question: Section 63(c)(5) applies to Bob's basic standard deduction in 2017. Contradiction

answer('s63_c_5_neg', Result) :- (s63_c_5("Bob", "Alice", _, 2017, _) -> Result = true ; Result = false).
