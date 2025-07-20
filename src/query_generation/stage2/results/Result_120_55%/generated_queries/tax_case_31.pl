% Stage 2 Generated Query
% Case: tax_case_31
% Question: How much tax does Alice have to pay in 2017? $6621

answer('tax_case_31', Result) :- (tax("Alice",2017,6621) -> Result = true ; Result = false).
