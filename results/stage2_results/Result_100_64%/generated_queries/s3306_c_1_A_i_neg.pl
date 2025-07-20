% Stage 2 Generated Query
% Case: s3306_c_1_A_i_neg
% Question: Section 3306(c)(1)(A)(i) applies to Alice employing Bob for the year 2017. Contradiction

answer('s3306_c_1_A_i_neg', Result) :- (s3306_c_1_A_i("Alice", _, "Bob", _, 2017) -> Result = true ; Result = false).
