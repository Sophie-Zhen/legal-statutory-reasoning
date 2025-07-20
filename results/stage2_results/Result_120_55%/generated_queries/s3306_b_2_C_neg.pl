% Stage 2 Generated Query
% Case: s3306_b_2_C_neg
% Question: Section 3306(b)(2)(C) applies to the payment Alice made to the retirement fund for the year 2017. Contradiction

answer('s3306_b_2_C_neg', Result) :- (s3306_b_2_C(_,_,_,"Alice",_,_) -> Result = true ; Result = false).
