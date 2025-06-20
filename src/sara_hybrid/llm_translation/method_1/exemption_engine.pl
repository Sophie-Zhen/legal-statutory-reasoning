% ----- exemption_engine.pl -----
:- module(exemption_engine,
          [ decide_exemption/4             % Person × Year × ClaimedAmt × Verdict
          ]).

:- use_module(section151).

%% § 151(d)(3)(A) reduction
exemption_due(Person, Year, Reduced) :-
    section151:exemption_base(Person,Year,Base),
    section151:applicable_pct(Person,Year,Pct),
    ReducedF is Base * Pct,
    Reduced is round(ReducedF).

decide_exemption(Person, Year, Claimed, entailment) :-
    exemption_due(Person, Year, Computed),
    Computed =:= Claimed.
decide_exemption(Person, Year, Claimed, contradiction) :-
    \+ decide_exemption(Person, Year, Claimed, entailment).