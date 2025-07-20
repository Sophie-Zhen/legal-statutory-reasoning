% ----- section1.pl -----
:- module(section1,
          [ bracket/6                     % FilingStatus × Year × Low × High × Base × Rate
          ]).

%% § 1(a): brackets for “married filing jointly” in 2017
bracket(married_filing_jointly, 2017, 0,      36900,   0,       0.15).
bracket(married_filing_jointly, 2017, 36900,  89150,   5535,    0.28).
bracket(married_filing_jointly, 2017, 89150, 140000,  20165,    0.31).
bracket(married_filing_jointly, 2017,140000, 250000,  35928.5,  0.36).
bracket(married_filing_jointly, 2017,250000,    inf,  75528.5,  0.396).

%% surviving spouses use the same schedule
bracket(surviving_spouse, Year, Low, High, Base, Rate) :-
    bracket(married_filing_jointly, Year, Low, High, Base, Rate).