% Stage 2 Generated Query
% Case: tax_case_68
% Question: How much tax does Alice have to pay in 2018? $28292

answer('tax_case_68', Result) :- (tax("Alice",2018,28292) -> Result = true ; Result = false).
