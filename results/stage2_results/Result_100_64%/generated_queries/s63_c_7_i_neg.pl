% Stage 2 Generated Query
% Case: s63_c_7_i_neg
% Question: Under section 63(c)(7)(i), Alice's basic standard deduction in 2019 is equal to $4400. Contradiction

answer('s63_c_7_i_neg', Result) :- (s63_c_7_i(2019, 4400) -> Result = true ; Result = false).
