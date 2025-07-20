% Stage 2 Generated Query
% Case: s3301_neg
% Question: Alice has to pay $26362 in excise tax for the year 2016 under section 3301. Contradiction

answer('s3301_neg', Result) :- (tax("Alice",2016,26362) -> Result = true ; Result = false).
