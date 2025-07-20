% Stage 2 Generated Query
% Case: tax_case_49
% Question: How much tax does Alice have to pay in 2015? $82819

answer('tax_case_49', Result) :- (tax("Alice",2015,82819) -> Result = true ; Result = false).
