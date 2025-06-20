% File: tests.pl
:- module(tests,[answer/2]).
:- use_module(section1).
:- use_module(section2).
:- use_module(section63).
:- use_module(section68).
:- use_module(section151).
:- use_module(section152).
:- use_module(section3301).
:- use_module(section3306).
:- use_module(section7703).
:- use_module(cases_data).

%% answer(CaseID, Result)
answer(CaseID, true)  :- case_type(CaseID, tax),
                         case_params(CaseID, [Status, TI, Expect]),
                         section1:tax(Status, TI, Tax),
                         round(Tax) =:= Expect.
answer(CaseID, false) :- case_type(CaseID, tax),
                         case_params(CaseID, [Status, TI, Expect]),
                         section1:tax(Status, TI, Tax),
                         round(Tax) =\= Expect.

answer(CaseID, true)  :- case_type(CaseID, boolean),
                         case_params(CaseID, [Pred|Args]),
                         Goal =.. [Pred|Args],
                         call(Goal).
answer(CaseID, false) :- case_type(CaseID, boolean),
                         case_params(CaseID, [Pred|Args]),
                         Goal =.. [Pred|Args],
                         \+ call(Goal).