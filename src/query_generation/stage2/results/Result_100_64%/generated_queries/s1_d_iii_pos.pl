% Stage 2 Generated Query
% Case: s1_d_iii_pos
% Question: Alice has to pay $17123 in taxes for the year 2017 under section 1(d)(iii). Entailment

answer('s1_d_iii_pos', Result) :- (s1_d_iii(67285, 17123) -> Result = true ; Result = false).
