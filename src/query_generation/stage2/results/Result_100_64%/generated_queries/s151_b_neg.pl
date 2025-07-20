% Stage 2 Generated Query
% Case: s151_b_neg
% Question: Alice can receive an exemption for Bob under section 151(b) for the year 2015. Contradiction

answer('s151_b_neg', Result) :- (s151_b("Alice", "Bob", _, 2015) -> Result = true ; Result = false).
