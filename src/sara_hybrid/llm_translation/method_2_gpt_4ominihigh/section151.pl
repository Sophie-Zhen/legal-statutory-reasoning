% File: section151.pl
:- module(section151,[exemption_amount/3]).

%% exemption_amount(AGI, Status, ExemptTotal)
exemption_amount(_AGI, _Status, 0) :-  % 2018–2025, exemptions = 0
    !.