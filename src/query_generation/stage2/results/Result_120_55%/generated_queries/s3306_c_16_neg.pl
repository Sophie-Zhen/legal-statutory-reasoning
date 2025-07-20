% Stage 2 Generated Query
% Case: s3306_c_16_neg
% Question: Section 3306(c)(16) applies to Alice's employment situation in 2017. Contradiction

answer('s3306_c_16_neg', Result) :- (s3306_c_16(span("employee",35,42), "United States Government") -> Result = true ; Result = false).
