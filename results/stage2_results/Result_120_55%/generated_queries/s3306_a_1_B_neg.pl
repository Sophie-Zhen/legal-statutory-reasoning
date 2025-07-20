% Stage 2 Generated Query
% Case: s3306_a_1_B_neg
% Question: Section 3306(a)(1)(B) applies to Alice for the year 2017. Contradiction

answer('s3306_a_1_B_neg', Result) :- (s3306_a_1_B("Alice", _, _, 2017) -> Result = true ; Result = false).
