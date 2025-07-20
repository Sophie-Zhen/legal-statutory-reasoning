% Stage 2 Generated Query
% Case: s1_a_1_iv_neg
% Question: Alice and her spouse have to pay $247647 in taxes for the year 2017 under section 1(a)(iv). Contradiction

answer('s1_a_1_iv_neg', Result) :- (tax("Alice",2017,247647) -> Result = true ; Result = false).
