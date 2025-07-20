% Stage 2 Generated Query
% Case: tax_case_82
% Question: How much tax does Bob have to pay in 2012? $986

answer('tax_case_82', Result) :- (tax("Bob",2012,986) -> Result = true ; Result = false).
