% Stage 2 Generated Query
% Case: tax_case_9
% Question: How much tax does Alice have to pay in 2018? $10598

answer('tax_case_9', Result) :- (tax("Alice",2018,10598) -> Result = true ; Result = false).
