% Stage 2 Generated Query
% Case: s152_a_neg
% Question: Under section 152(a), Bob is a dependent of Alice for the year 2014. Contradiction

answer('s152_a_neg', Result) :- (s152_a("Bob","Alice",2014) -> Result = true ; Result = false).
