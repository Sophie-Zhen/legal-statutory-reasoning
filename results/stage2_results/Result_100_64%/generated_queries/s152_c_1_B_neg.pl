% Stage 2 Generated Query
% Case: s152_c_1_B_neg
% Question: Section 152(c)(1)(B) applies to Bob with Alice as the taxpayer for the year 2015. Contradiction

answer('s152_c_1_B_neg', Result) :- (s152_c_1_B("Bob", _, "Alice", _, _, 2015) -> Result = true ; Result = false).
