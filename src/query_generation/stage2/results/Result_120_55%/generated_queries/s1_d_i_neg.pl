% Stage 2 Generated Query
% Case: s1_d_i_neg
% Question: Alice has to pay $17123 in taxes for the year 2017 under section 1(d)(i). Contradiction

answer('s1_d_i_neg', Result) :- (s1_d_i(67285, 17123) -> Result = true ; Result = false).
