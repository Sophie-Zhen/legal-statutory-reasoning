% Stage 2 Generated Query
% Case: s3306_c_B_neg
% Question: Section 3306(c)(B) applies to Alice employing Bob for the year 2017. Contradiction

answer('s3306_c_B_neg', Result) :- (s3306_c_B(span("work",32,35), "Alice", "Bob", _) -> Result = true ; Result = false).
