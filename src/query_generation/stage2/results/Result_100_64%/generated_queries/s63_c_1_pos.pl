% Stage 2 Generated Query
% Case: s63_c_1_pos
% Question: Under section 63(c)(1), Alice's standard deduction in 2017 is equal to $5000. Entailment

answer('s63_c_1_pos', Result) :- (s63_c_1("Alice", 2017, 5000) -> Result = true ; Result = false).
