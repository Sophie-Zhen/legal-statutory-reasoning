% Stage 2 Generated Query
% Case: s3306_a_3_pos
% Question: Section 3306(a)(3) applies to Bob for the year 2018. Entailment

answer('s3306_a_3_pos', Result) :- (s3306_a_3("Bob", _, _, 2018) -> Result = true ; Result = false).
