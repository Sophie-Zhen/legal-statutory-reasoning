% Stage 2 Generated Query
% Case: s3306_a_1_B_pos
% Question: Section 3306(a)(1)(B) applies to Alice for the year 2017. Entailment

answer('s3306_a_1_B_pos', Result) :- (s3306_a_1_A("Alice",_,2017) -> Result = true ; Result = false).
