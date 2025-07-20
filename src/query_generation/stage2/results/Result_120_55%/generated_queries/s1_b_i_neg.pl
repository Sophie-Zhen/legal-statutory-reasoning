% Stage 2 Generated Query
% Case: s1_b_i_neg
% Question: Alice has to pay $442985 in taxes for the year 2017 under section 1(b)(i). Contradiction

answer('s1_b_i_neg', Result) :- (tax("Alice",2017,442985) -> Result = true ; Result = false).
