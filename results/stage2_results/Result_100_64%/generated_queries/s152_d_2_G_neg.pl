% Stage 2 Generated Query
% Case: s152_d_2_G_neg
% Question: Alice bears a relationship to Bob under section 152(d)(2)(G) for the year 2018. Contradiction

answer('s152_d_2_G_neg', Result) :- (s152_d_2_G("Alice", "Bob", _, _) -> Result = true ; Result = false).
