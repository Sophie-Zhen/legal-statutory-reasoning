% Stage 2 Generated Query
% Case: tax_case_43
% Question: How much tax does Alice have to pay in 2017? $8439

answer('tax_case_43', Result) :- (tax("Alice",2017,8439) -> Result = true ; Result = false).
