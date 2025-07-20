% Stage 2 Generated Query
% Case: s152_d_2_C_pos
% Question: Alice bears a relationship to Bob under section 152(d)(2)(C). Entailment

answer('s152_d_2_C_pos', Result) :- (s152_d_2_C("Alice", "Bob", _, _) -> Result = true ; Result = false).
