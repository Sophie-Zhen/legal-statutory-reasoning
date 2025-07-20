% Stage 2 Generated Query
% Case: s3306_b_2_C_pos
% Question: Section 3306(b)(2)(C) applies to the payment Alice made to the life insurance fund for the year 2017. Entailment

answer('s3306_b_2_C_pos', Result) :- (s3306_b_2_C(_,_,_,"Alice",_,_) -> Result = true ; Result = false).
