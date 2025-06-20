% File: section152.pl
:- module(section152,[qualifying_child/3, qualifying_relative/3]).

%% qualifying_child(Child, Taxpayer, Year)
% Relationship + abode + age + joint-return check
qualifying_child(Child, Taxpayer, _Year) :-
    % assume per-case facts: child_of(Taxpayer,Child), lives_together/4, birth(Child, Y-M-D), age < 25 ; etc.
    child_of(Taxpayer, Child).

%% qualifying_relative(Rel, Taxpayer, Year)
qualifying_relative(Rel, Taxpayer, _Year) :-
    % assume per-case facts: relative_of/2, income(Rel, 0), \+ qualifying_child(Rel, _, _)
    relative_of(Rel, Taxpayer),
    income(Rel, 0),
    \+ qualifying_child(Rel, Taxpayer, _).