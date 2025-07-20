% Stage 2 Generated Query
% Case: s63_c_5_pos
% Question: Under section 63(c)(5), Bob's basic standard deduction in 2017 is equal to at most $500. Entailment

answer('s63_c_5_pos', Result) :- ((s63_c_5("Bob", _, _, 2017, Deduction), Deduction =< 500) -> Result = true ; Result = false).
