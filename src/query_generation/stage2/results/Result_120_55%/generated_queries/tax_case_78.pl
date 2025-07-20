% Stage 2 Generated Query
% Case: tax_case_78
% Question: How much tax does Alice have to pay in 2019? $14470

answer('tax_case_78', Result) :- (tax("Alice",2019,14470) -> Result = true ; Result = false).
