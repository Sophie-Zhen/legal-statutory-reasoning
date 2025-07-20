% Stage 2 Generated Query
% Case: s152_c_3_neg
% Question: Bob satisfies section 152(c)(3) with Alice claiming Bob as a qualifying child for the year 2019. Contradiction

answer('s152_c_3_neg', Result) :- (s152_c_3("Bob", "Alice", 2019) -> Result = true ; Result = false).
