% Stage 2 Generated Query
% Case: s1_a_1_pos
% Question: Alice and her husband have to pay $2600 in taxes for the year 2017 under section 1(a). Entailment

answer('s1_a_1_pos', Result) :- (tax("Alice",2017,2600) -> Result = true ; Result = false).
