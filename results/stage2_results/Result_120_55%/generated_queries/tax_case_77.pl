% Stage 2 Generated Query
% Case: tax_case_77
% Question: How much tax does Alice have to pay in 2023? $6449

answer('tax_case_77', Result) :- (tax("Alice",2023,6449) -> Result = true ; Result = false).
