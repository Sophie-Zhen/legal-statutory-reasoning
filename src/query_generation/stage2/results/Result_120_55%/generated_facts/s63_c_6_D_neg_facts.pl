% Stage 2 Generated Facts
% Case: s63_c_6_D_neg
% Text: From 1973 to 2019, the Walter Brown Family Trust II was considered to be a business trust.
% Question: Section 63(c)(6)(D) applies to the Walter Brown Family Trust II for 2021. Contradiction

:- discontiguous s63_c_6_D_applies/2.
:- ['statutes/prolog/init'].
business_trust_(span("business trust",78,91)).
agent_(span("business trust",78,91),span("the Walter Brown Family Trust II",22,52)).
start_(span("business trust",78,91),span(1973,5,8)).
end_(span("business trust",78,91),span(2019,13,16)).
s63_c_6_D_applies("the Walter Brown Family Trust II",2021).
