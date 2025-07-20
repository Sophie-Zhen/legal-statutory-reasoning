% Stage 2 Generated Query
% Case: s3306_c_6_neg
% Question: Section 3306(c)(6) applies to Alice's employment situation in 2017. Contradiction

answer('s3306_c_6_neg', Result) :- (s3306_c_6(span("employee",36,43)) -> Result = true ; Result = false).
