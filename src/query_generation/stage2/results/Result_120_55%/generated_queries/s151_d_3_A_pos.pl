% Stage 2 Generated Query
% Case: s151_d_3_A_pos
% Question: Under section 151(d)(3)(A), Alice's exemption amount is reduced to $1800. Entailment

answer('s151_d_3_A_pos', Result) :- (s151_d_3_A("Alice",_,_,_,2000,1800,2017) -> Result = true ; Result = false).
