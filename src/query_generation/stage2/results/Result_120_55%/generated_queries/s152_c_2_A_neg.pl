% Stage 2 Generated Query
% Case: s152_c_2_A_neg
% Question: Bob bears a relationship to Alice under section 152(c)(2)(A). Contradiction

answer('s152_c_2_A_neg', Result) :- (s152_c_2_A("Bob", "Alice", _, _, _) -> Result = true ; Result = false).
