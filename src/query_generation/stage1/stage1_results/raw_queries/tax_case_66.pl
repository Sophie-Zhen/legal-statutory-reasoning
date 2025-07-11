case_query(Result) :-
    bagof(Year, (bob_household_maintenance(Year, _, _, _), s152_c_1(Year)), Years),
    member(2016, Years),
    Result = true.