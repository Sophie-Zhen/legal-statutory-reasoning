% Stage 2 Generated Query
% Case: tax_case_34
% Question: How much tax does Alice have to pay in 2017? $2684

answer('tax_case_34', Result) :- (tax("Alice",2017,2684) -> Result = true ; Result = false).
