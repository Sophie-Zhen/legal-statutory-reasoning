answer('s3306_c_5_pos', Result) :- 
    (s3306_c_5([_,alice,bob,_], _, _, 2017) -> Result = true ; Result = false).