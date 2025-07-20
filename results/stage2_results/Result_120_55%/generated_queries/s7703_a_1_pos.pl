% Stage 2 Generated Query
% Case: s7703_a_1_pos
% Question: Section 7703(a)(1) applies to Alice for the year 2012. Entailment

answer('s7703_a_1_pos', Result) :- (s7703_a_1("Alice", "Bob", _, _, 2012) -> Result = true ; Result = false).
