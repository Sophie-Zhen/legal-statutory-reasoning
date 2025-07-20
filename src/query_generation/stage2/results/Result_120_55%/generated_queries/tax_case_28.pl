% Stage 2 Generated Query
% Case: tax_case_28
% Question: How much tax does Alice have to pay in 2017? $344848

answer('tax_case_28', Result) :- (tax("Alice",2017,344848) -> Result = true ; Result = false).
