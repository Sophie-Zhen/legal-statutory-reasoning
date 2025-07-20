% Stage 2 Generated Query
% Case: s3301_pos
% Question: Alice has to pay $27181 in excise tax for the year 2015 under section 3301. Entailment

answer('s3301_pos', Result) :- (tax("Alice",2015,27181) -> Result = true ; Result = false).
