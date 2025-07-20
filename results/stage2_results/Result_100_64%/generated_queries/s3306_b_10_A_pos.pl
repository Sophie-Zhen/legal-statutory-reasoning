% Stage 2 Generated Query
% Case: s3306_b_10_A_pos
% Question: Section 3306(b)(10)(A) applies to the payment of $12980 that Alice made in 2019. Entailment

answer('s3306_b_10_A_pos', Result) :- (tax("Alice",2019,12980) -> Result = true ; Result = false).
