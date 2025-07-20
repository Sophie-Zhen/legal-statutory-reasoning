% Stage 2 Generated Query
% Case: tax_case_85
% Question: How much tax does Alice have to pay in 2019? $2477

answer('tax_case_85', Result) :- (tax("Alice",2019,2477) -> Result = true ; Result = false).
