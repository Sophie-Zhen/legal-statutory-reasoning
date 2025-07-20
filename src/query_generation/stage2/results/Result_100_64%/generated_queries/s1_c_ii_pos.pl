% Stage 2 Generated Query
% Case: s1_c_ii_pos
% Question: Alice has to pay $3538 in taxes for the year 2017 under section 1(c)(ii). Entailment

answer('s1_c_ii_pos', Result) :- (s1_c_ii(22895, 3538) -> Result = true ; Result = false).
