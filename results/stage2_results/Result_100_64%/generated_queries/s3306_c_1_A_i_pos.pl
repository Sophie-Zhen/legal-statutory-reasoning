% Stage 2 Generated Query
% Case: s3306_c_1_A_i_pos
% Question: Section 3306(c)(1)(A)(i) applies to Alice employing Bob for the year 2017. Entailment

answer('s3306_c_1_A_i_pos', Result) :- (s3306_c_1_A_i("Alice", _, _, _, 2017) -> Result = true ; Result = false).
