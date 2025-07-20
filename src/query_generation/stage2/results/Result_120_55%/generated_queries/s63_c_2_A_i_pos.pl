% Stage 2 Generated Query
% Case: s63_c_2_A_i_pos
% Question: Section 63(c)(2)(A)(i) applies to Alice in 2017. Entailment

answer('s63_c_2_A_i_pos', Result) :- (s63_c_2_A_i("Alice", _, 2017) -> Result = true ; Result = false).
