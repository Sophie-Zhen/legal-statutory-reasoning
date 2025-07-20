% Stage 2 Generated Query
% Case: s3306_c_11_pos
% Question: Section 3306(c)(11) applies to Alice's employment situation in 2017. Entailment

answer('s3306_c_11_pos', Result) :- (s3306_b_11(span("employment",_,_),_,_) -> Result = true ; Result = false).
