% Stage 2 Generated Query
% Case: s3306_c_5_neg
% Question: Section 3306(c)(5) applies to Alice employing Bob for the year 2017. Contradiction

answer('s3306_c_5_neg', Result) :- (s3306_c_5(_, "Alice", "Bob", _) -> Result = true ; Result = false).
