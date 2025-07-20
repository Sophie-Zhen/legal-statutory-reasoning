% Stage 2 Generated Query
% Case: tax_case_75
% Question: How much tax does Alice have to pay in 2012? $8883

answer('tax_case_75', Result) :- (tax("Alice",2012,8883) -> Result = true ; Result = false).
