% Stage 2 Generated Query
% Case: s3306_c_7_neg
% Question: Section 3306(c)(7) applies to Alice's employment situation in 2017. Contradiction

answer('s3306_c_7_neg', Result) :- (s3306_c_7(span("employee",35,42), span("Bertha's Mussels",47,62)) -> Result = true ; Result = false).
