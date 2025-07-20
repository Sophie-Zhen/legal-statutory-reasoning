% Stage 2 Generated Query
% Case: tax_case_69
% Question: How much tax does Alice have to pay in 2014? $264225

answer('tax_case_69', Result) :- (tax("Alice",2014,264225) -> Result = true ; Result = false).
