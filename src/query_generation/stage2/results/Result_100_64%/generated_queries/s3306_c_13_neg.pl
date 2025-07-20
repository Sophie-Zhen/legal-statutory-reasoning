% Stage 2 Generated Query
% Case: s3306_c_13_neg
% Question: Section 3306(c)(13) applies to Alice's employment situation in 2017. Contradiction

answer('s3306_c_13_neg', Result) :- (s3306_c_13(_, "Johns Hopkins University", "Alice", _) -> Result = true ; Result = false).
