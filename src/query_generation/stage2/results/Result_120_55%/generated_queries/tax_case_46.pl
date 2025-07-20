% Stage 2 Generated Query
% Case: tax_case_46
% Question: How much tax does Alice have to pay in 2020? $17399

answer('tax_case_46', Result) :- (tax("Alice",2020,17399) -> Result = true ; Result = false).
