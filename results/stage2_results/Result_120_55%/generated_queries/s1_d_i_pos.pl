% Stage 2 Generated Query
% Case: s1_d_i_pos
% Question: Alice has to pay $999 in taxes for the year 2017 under section 1(d)(i). Entailment

answer('s1_d_i_pos', Result) :- (tax("Alice",2017,999) -> Result = true ; Result = false).
