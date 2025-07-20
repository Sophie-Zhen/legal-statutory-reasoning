% Stage 2 Generated Query
% Case: s3306_c_B_pos
% Question: Section 3306(c)(B) applies to Alice employing Bob for the year 2017. Entailment

answer('s3306_c_B_pos', Result) :- (s3306_c_A(span(_,_,_),"Alice",_) -> Result = true ; Result = false).
