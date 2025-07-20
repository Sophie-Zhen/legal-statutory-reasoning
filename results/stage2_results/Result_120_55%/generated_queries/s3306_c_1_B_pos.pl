% Stage 2 Generated Query
% Case: s3306_c_1_B_pos
% Question: Section 3306(c)(1)(B) applies to Alice employing Bob for the year 2017. Entailment

answer('s3306_c_1_B_pos', Result) :- (s3306_c_1(span(_,_,_),2017) -> Result = true ; Result = false).
