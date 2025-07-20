% Stage 2 Generated Query
% Case: tax_case_90
% Question: How much tax does Bob have to pay in 2018? $96641

answer('tax_case_90', Result) :- (tax("Bob",2018,96641) -> Result = true ; Result = false).
