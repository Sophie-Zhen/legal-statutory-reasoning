% Stage 2 Generated Query
% Case: s3306_b_15_neg
% Question: Section 3306(b)(15) applies to the payment that Alice made to Charlie in 2019. Contradiction

answer('s3306_b_15_neg', Result) :- (s3306_b_15(span("paid",170,173), "Alice", "Charlie", "Bob", 2019) -> Result = true ; Result = false).
