% Stage 2 Generated Query
% Case: s1_c_iii_neg
% Question: Alice has to pay $3538 in taxes for the year 2017 under section 1(c)(iii). Contradiction

answer('s1_c_iii_neg', Result) :- (tax("Alice",2017,3538) -> Result = true ; Result = false).
