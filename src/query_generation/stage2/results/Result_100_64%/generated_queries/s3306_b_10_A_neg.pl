% Stage 2 Generated Query
% Case: s3306_b_10_A_neg
% Question: Section 3306(b)(10)(A) applies to the payment of $12980 that Alice made in 2019. Contradiction

answer('s3306_b_10_A_neg', Result) :- (tax("Alice",2019,12980) -> Result = true ; Result = false).
