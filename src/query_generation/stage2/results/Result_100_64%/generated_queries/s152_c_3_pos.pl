% Stage 2 Generated Query
% Case: s152_c_3_pos
% Question: Bob satisfies section 152(c)(3) with Alice claiming Bob as a qualifying child for the year 2019. Entailment

answer('s152_c_3_pos', Result) :- (s152_c_3("Bob", "Alice", 2019) -> Result = true ; Result = false).
