case_query(Result) :-
    s152_d_2_H(C,B,Y,_,SD,ED),
    payment_(P),
    agent_(P,Agent_p),
    double_equal(B,Agent_p),
    start_(P,Start_p),
    end_(P,End_p),
    double_equal(SD,Start_p),
    double_equal(ED,End_p),
    Result = true.