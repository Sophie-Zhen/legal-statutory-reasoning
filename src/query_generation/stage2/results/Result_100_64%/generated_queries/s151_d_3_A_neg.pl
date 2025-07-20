% Stage 2 Generated Query
% Case: s151_d_3_A_neg
% Question: Under section 151(d)(3)(A), Alice's exemption amount is reduced to $1900. Contradiction

answer('s151_d_3_A_neg', Result) :- (s151_d_3_A("Alice",_,_,_,2000,1900,1900) -> Result = true ; Result = false).
