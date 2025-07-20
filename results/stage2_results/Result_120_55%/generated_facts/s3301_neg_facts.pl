% Stage 2 Generated Facts
% Case: s3301_neg
% Text: Alice is an employer under section 3306(a) for the year 2015 and 2016, and she has paid $453009 in total wages in 2015, and $443870 in 2016.
% Question: Alice has to pay $26362 in excise tax for the year 2016 under section 3301. Contradiction

:- discontiguous s3306_a/2.
:- discontiguous wages_paid/3.
:- ['statutes/prolog/init'].
s3306_a("Alice", 2015).
s3306_a("Alice", 2016).
wages_paid("Alice", 453009, 2015).
wages_paid("Alice", 443870, 2016).
