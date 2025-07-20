% Stage 2 Generated Query
% Case: s1_c_iii_pos
% Question: Alice has to pay $27225 in taxes for the year 2017 under section 1(c)(iii). Entailment

answer('s1_c_iii_pos', Result) :- (tax("Alice",2017,27225) -> Result = true ; Result = false).
