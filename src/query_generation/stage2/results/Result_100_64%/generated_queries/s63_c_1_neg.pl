% Stage 2 Generated Query
% Case: s63_c_1_neg
% Question: Under section 63(c)(1), Alice's standard deduction in 2017 is equal to $4000. Contradiction

answer('s63_c_1_neg', Result) :- (s63_c_1("Alice", 2017, 4000) -> Result = true ; Result = false).
