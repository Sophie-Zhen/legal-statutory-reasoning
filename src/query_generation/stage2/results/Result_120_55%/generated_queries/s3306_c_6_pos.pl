% Stage 2 Generated Query
% Case: s3306_c_6_pos
% Question: Section 3306(c)(6) applies to Alice's employment situation in 2017. Entailment

answer('s3306_c_6_pos', Result) :- (s3306_c_6(span("employee",35,42)) -> Result = true ; Result = false).
