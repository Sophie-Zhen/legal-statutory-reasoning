% Stage 2 Generated Query
% Case: tax_case_57
% Question: How much tax does Alice have to pay in 2017? $4073

answer('tax_case_57', Result) :- (tax("Alice",2017,4073) -> Result = true ; Result = false).
