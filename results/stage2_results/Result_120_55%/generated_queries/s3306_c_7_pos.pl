% Stage 2 Generated Query
% Case: s3306_c_7_pos
% Question: Section 3306(c)(7) applies to Alice's employment situation in 2017. Entailment

answer('s3306_c_7_pos', Result) :- (s3306_c(span("employment",_,_),2017) -> Result = true ; Result = false).
