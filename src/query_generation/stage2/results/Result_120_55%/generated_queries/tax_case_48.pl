% Stage 2 Generated Query
% Case: tax_case_48
% Question: How much tax does Bob have to pay in 2018? $33068

answer('tax_case_48', Result) :- (tax("Bob",2018,33068) -> Result = true ; Result = false).
