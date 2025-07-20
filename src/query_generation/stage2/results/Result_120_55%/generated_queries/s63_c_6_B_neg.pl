% Stage 2 Generated Query
% Case: s63_c_6_B_neg
% Question: Section 63(c)(6)(B) applies to Alice for 2017. Contradiction

answer('s63_c_6_B_neg', Result) :- (s63_c_6_B("Alice", 2017) -> Result = true ; Result = false).
