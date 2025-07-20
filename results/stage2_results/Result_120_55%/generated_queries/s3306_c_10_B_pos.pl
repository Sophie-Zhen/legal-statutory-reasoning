% Stage 2 Generated Query
% Case: s3306_c_10_B_pos
% Question: Section 3306(c)(10)(B) applies to Alice's employment situation in 2017. Entailment

answer('s3306_c_10_B_pos', Result) :- (s3306_c_10_A_i("Alice",_,2017) -> Result = true ; Result = false).
