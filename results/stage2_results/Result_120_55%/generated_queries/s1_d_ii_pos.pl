% Stage 2 Generated Query
% Case: s1_d_ii_pos
% Question: Alice has to pay $5683 in taxes for the year 2017 under section 1(d)(ii). Entailment

answer('s1_d_ii_pos', Result) :- (tax("Alice",2017,5683) -> Result = true ; Result = false).
