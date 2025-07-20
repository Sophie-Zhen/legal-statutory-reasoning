% Stage 2 Generated Query
% Case: s63_f_1_A_neg
% Question: Section 63(f)(1)(A) applies to Bob in 2017. Contradiction

answer('s63_f_1_A_neg', Result) :- (s63_f_1_A("Bob", 2017) -> Result = true ; Result = false).
