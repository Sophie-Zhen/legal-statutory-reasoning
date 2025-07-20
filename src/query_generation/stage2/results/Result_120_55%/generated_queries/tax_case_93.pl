% Stage 2 Generated Query
% Case: tax_case_93
% Question: How much tax does Alice have to pay in 2015? $102150

answer('tax_case_93', Result) :- (tax("Alice",2015,102150) -> Result = true ; Result = false).
