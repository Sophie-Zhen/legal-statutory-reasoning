% Stage 2 Generated Facts
% Case: s152_c_3_neg
% Text: Alice was born January 10th, 1992. Bob was born January 31st, 1984. Alice adopted Bob on March 4th, 2018.
% Question: Bob satisfies section 152(c)(3) with Alice claiming Bob as a qualifying child for the year 2019. Contradiction

:- ['statutes/prolog/init'].
birth_(span("born",10,13)).
agent_(span("born",10,13),span("Alice",0,4)).
start_(span("born",10,13),span(19920110,15,34)).
birth_(span("born",45,48)).
agent_(span("born",45,48),span("Bob",37,39)).
start_(span("born",45,48),span(19840131,50,69)).
adoption_(span("adopted",78,84)).
agent_(span("adopted",78,84),span("Alice",72,76)).
patient_(span("adopted",78,84),span("Bob",86,88)).
start_(span("adopted",78,84),span(20180304,93,108)).
