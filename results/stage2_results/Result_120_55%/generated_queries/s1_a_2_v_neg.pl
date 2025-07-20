% Stage 2 Generated Query
% Case: s1_a_2_v_neg
% Question: Alice has to pay $3834 in taxes for the year 2017 under section 1(a)(v). Contradiction

answer('s1_a_2_v_neg', Result) :- (tax("Alice",2017,3834) -> Result = true ; Result = false).
