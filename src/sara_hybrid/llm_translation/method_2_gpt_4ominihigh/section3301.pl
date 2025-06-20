% File: section3301.pl
:- module(section3301,[excise_tax/2]).

%% excise_tax(Wages, Tax).
excise_tax(W, Tax) :-
    Tax is W * 0.06.