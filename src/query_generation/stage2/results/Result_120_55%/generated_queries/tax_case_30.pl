% Stage 2 Generated Query
% Case: tax_case_30
% Question: How much tax does Alice have to pay in 2017? $249

answer('tax_case_30', Result) :- (tax("Alice",2017,249) -> Result = true ; Result = false).
