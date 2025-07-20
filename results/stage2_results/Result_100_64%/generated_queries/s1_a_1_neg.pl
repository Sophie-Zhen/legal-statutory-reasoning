% Stage 2 Generated Query
% Case: s1_a_1_neg
% Question: Alice has to pay $24056 in taxes for the year 2017 under section 1(a). Contradiction

answer('s1_a_1_neg', Result) :- (s1_a("Alice", 2017, _, 24056) -> Result = true ; Result = false).
