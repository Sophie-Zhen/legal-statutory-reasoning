% Stage 2 Generated Query
% Case: s1_a_2_v_pos
% Question: Alice has to pay $220295 in taxes for the year 2017 under section 1(a)(v). Entailment

answer('s1_a_2_v_pos', Result) :- (s1_a_v(615572, 220295) -> Result = true ; Result = false).
