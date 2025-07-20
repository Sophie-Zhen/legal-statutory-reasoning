% Stage 2 Generated Query
% Case: s152_a_pos
% Question: Under section 152(a), Bob is a dependent of Alice for the year 2015. Entailment

answer('s152_a_pos', Result) :- (s152_a("Bob", "Alice", 2015) -> Result = true ; Result = false).
