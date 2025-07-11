case_query(Result) :- s151_c_applies("Bob","Charlie",2018), Result=true.
case_query(Result) :- \+ s151_c_applies("Bob","Charlie",2018), Result=false.