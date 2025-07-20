% Stage 2 Generated Query
% Case: s1_c_neg
% Question: Alice and her spouse have to pay $2600 in taxes for the year 2017 under section 1(c). Contradiction

answer('s1_c_neg', Result) :- (s1_c("Alice", 2017, _, 2600) -> Result = true ; Result = false).
