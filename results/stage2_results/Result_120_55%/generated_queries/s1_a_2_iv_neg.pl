% Stage 2 Generated Query
% Case: s1_a_2_iv_neg
% Question: Alice has to pay $220295 in taxes for the year 2017 under section 1(a)(iv). Contradiction

answer('s1_a_2_iv_neg', Result) :- (tax("Alice",2017,220295) -> Result = true ; Result = false).
