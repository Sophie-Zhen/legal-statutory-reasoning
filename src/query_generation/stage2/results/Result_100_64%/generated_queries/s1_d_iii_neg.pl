% Stage 2 Generated Query
% Case: s1_d_iii_neg
% Question: Alice has to pay $999 in taxes for the year 2017 under section 1(d)(iii). Contradiction

answer('s1_d_iii_neg', Result) :- (tax("Alice",2017,999) -> Result = true ; Result = false).
