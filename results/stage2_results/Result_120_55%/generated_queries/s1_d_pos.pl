% Stage 2 Generated Query
% Case: s1_d_pos
% Question: Alice has to pay $207772 in taxes for the year 2017 under section 1(d). Entailment

answer('s1_d_pos', Result) :- (s1_d("Alice", _, 2017, _, 207772) -> Result = true ; Result = false).
