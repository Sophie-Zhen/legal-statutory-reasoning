% Stage 2 Generated Query
% Case: tax_case_53
% Question: How much tax does Alice have to pay in 2020? $206332

answer('tax_case_53', Result) :- (tax("Alice",2020,206332) -> Result = true ; Result = false).
