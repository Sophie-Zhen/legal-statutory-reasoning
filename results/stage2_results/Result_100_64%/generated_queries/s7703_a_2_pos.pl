% Stage 2 Generated Query
% Case: s7703_a_2_pos
% Question: Section 7703(a)(2) applies to Alice for the year 2018. Entailment

answer('s7703_a_2_pos', Result) :- (s7703_a_2("Alice", _, _, _, 2018) -> Result = true ; Result = false).
