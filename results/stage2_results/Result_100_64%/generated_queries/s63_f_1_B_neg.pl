% Stage 2 Generated Query
% Case: s63_f_1_B_neg
% Question: Section 63(f)(1)(B) applies to Alice with Bob as the spouse in 2017. Contradiction

answer('s63_f_1_B_neg', Result) :- (s63_f_1_B("Alice", "Bob", 2017) -> Result = true ; Result = false).
